//
//  Movie.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Metal
import AVFoundation
import Combine
import AppKit.NSEvent

/**
 * Play a movie.
 * Can be set to loop and can also be muted.
 */
class MovieContent: Content, TextureContent {

    var size: simd_int2 = .zero
    var textures: [MTLTexture]?
    var texture: MTLTexture?

    var loop = false
    var mute = false

    static let pixelFormatType = kCVPixelFormatType_64RGBAHalf
//    static let pixelFormatType = kCVPixelFormatType_32BGRA

    let visualOutputSettings: [String:Any] = [

//        AVVideoColorPropertiesKey: [
//            AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
//            AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
//            AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2
//        ],
        AVVideoColorPropertiesKey: [
            AVVideoColorPrimariesKey: AVVideoColorPrimaries_P3_D65,
            AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_2100_HLG,
            AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_2020
        ],
        kCVPixelBufferPixelFormatTypeKey as String: pixelFormatType,
        kCVPixelBufferMetalCompatibilityKey as String: true
    ]
    let audibleOutputSettings: [String:Any] = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMIsNonInterleaved: true, AVLinearPCMIsFloatKey: true, AVLinearPCMBitDepthKey: 32]
    let asset: AVAsset
    var reader: AssetReader
    var audiblePlayer: AudiblePlayer?
    var volume: Float {
        get {
            audiblePlayer?.volume ?? 0
        }
        set {
            audiblePlayer?.volume = newValue
        }
    }
    var position: Float {
        get {
            let elapsed = CACurrentMediaTime() - startTime
            let duration = asset.duration.seconds
            return Float(elapsed / duration)
        }
        set {
            seek(to: newValue)
        }
    }

    convenience init(path: String, loop: Bool?, mute: Bool?) throws {
        try self.init(url: URL(fileURLWithPath: path))
        self.loop = loop == true
        self.mute = mute == true
    }

    init(url: URL) throws {
        print("MovieContent.init")
        asset = AVAsset(url: url)
        reader = try AssetReader(asset: asset, visualOutputSettings: visualOutputSettings, audibleOutputSettings: audibleOutputSettings, timeRange: nil)
        if reader.audibleOutput != nil {
            audiblePlayer = AudiblePlayer()
        }
        reader.startReading()
        size = reader.naturalSize
    }

    deinit {
        print("MovieContent.deinit")
        token?.cancel()
        reader.cancelReading()
    }

    func restart() throws {
        print("MovieContent.restart")
        reader = try AssetReader(asset: asset, visualOutputSettings: visualOutputSettings, audibleOutputSettings: audibleOutputSettings, timeRange: nil)
        startTime += asset.duration.seconds
        reader.startReading()
    }

    fileprivate var token: AnyCancellable?
    func start() {
        startTime = CACurrentMediaTime() - stopTime
        token = engine.contentTick.sink { [weak self] in
            guard let self else { return }
            Task { self.step() }
        }
    }

    func stop() {
        token = nil
        stopTime = CACurrentMediaTime() - startTime
    }

    func seek(to position: Float) {
        if semaphore.wait(timeout: .distantFuture) == .timedOut { return }
        defer { semaphore.signal() }

        let duration = asset.duration
        let num = CMTimeValue(Float(duration.value) * position)
        let timeRange = CMTimeRange(start: CMTime(value: num, timescale: duration.timescale), duration: .positiveInfinity)
        do {
            reader = try AssetReader(asset: asset, visualOutputSettings: visualOutputSettings, audibleOutputSettings: audibleOutputSettings, timeRange: timeRange)
            reader.startReading()
            startTime = CACurrentMediaTime() - duration.seconds * Double(position)
            visualPeek = nil
            audiblePeek = nil
        }
        catch { print("error", error) }
    }

    fileprivate var startTime: CFTimeInterval = 0
    fileprivate var stopTime: CFTimeInterval = 0
    fileprivate var visualPeek: CMSampleBuffer?
    fileprivate var audiblePeek: CMSampleBuffer?

    let semaphore = DispatchSemaphore(value: 1)

    func step() {
        if semaphore.wait(timeout: .now()) == .timedOut { return }
        defer { semaphore.signal() }

        if reader.status == .completed, loop {
            do {
                try restart()
            } catch {
                reader.cancelReading()
            }
            return
        }
        let elapsed = CACurrentMediaTime() - startTime

        if let audibleOutput = reader.audibleOutput {
            while true {
                if audiblePeek == nil {
                    audiblePeek = audibleOutput.copyNextSampleBuffer()
                }
                if let current = audiblePeek, elapsed > current.presentationTimeStamp.seconds {
                    publishAudible(current)
                    self.audiblePeek = nil
                } else {
                    break
                }
            }
        }

        if let visualOutput = reader.visualOutput {
            while true {
                if visualPeek == nil {
                    visualPeek = visualOutput.copyNextSampleBuffer()
                }
                if let current = visualPeek, elapsed > current.presentationTimeStamp.seconds {
                    do {
                        try publishVisual(current)
                    } catch { print(error) }
                    self.visualPeek = nil
                } else {
                    break
                }
            }
        }

    }

    func publishAudible(_ sampleBuffer: CMSampleBuffer) {
        if !mute {
            self.audiblePlayer?.receive(sampleBuffer)
        }
    }

    var imageBuffers = [CVImageBuffer]()
    func publishVisual(_ sampleBuffer: CMSampleBuffer) throws {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            /*  Keep a reference to the imagebuffer to prevent reuse by the decoder
                while it's metal texture is still needed for display. */
            self.imageBuffers.append(imageBuffer)
            while self.imageBuffers.count > 2 {
                self.imageBuffers.removeFirst()
            }
            var textures = [MTLTexture]()

            // rgb has 0 planes
            let planes = max(CVPixelBufferGetPlaneCount(imageBuffer), 1)
            let pixelFormats: [MTLPixelFormat] = [.rgba16Float]
            (0...(planes-1)).forEach { i in
                let width = CVPixelBufferGetWidthOfPlane(imageBuffer, i)
                let height = CVPixelBufferGetHeightOfPlane(imageBuffer, i)
                var metalTexture: CVMetalTexture?
                CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, engine.textureCache, imageBuffer, nil, pixelFormats[i], width, height, i, &metalTexture);
                guard let metalTexture = metalTexture else {
                    print("error", "metalTexture")
                    return
                }
                guard let texture = CVMetalTextureGetTexture(metalTexture) else {
                    print("error", "CVMetalTextureGetTexture")
                    return
                }
                textures.append(texture)
            }
            self.textures = textures
            self.texture = self.textures?.first
        } else {
            print("could not get imagebuffer", sampleBuffer)
        }
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        if let textures = textures {
            for (i, texture) in textures.enumerated() {
                if let index = TextureIndex.init(rawValue: i + 1) {
                    renderEncoder.setFragmentTexture(texture, index: index.rawValue)
                }
            }
            renderEncoder.setRenderPipelineState(engine.pipelineContent)
            return true
        }
        return false
    }

    func onEvent(_ event: NSEvent, at point: simd_float2) {
        if event.type == .leftMouseDown {
            seek(to: point.x)
        }
        if event.type == .scrollWheel {
            var volume = self.volume + Float(event.deltaY)
            volume = max(0, volume)
            volume = min(1, volume)
            self.volume = volume
        }
    }

}

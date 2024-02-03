//
//  FF.swift
//  Texel
//
//  Created by Phillip Gerhardt on 09.04.23.
//

import Foundation

import Quartz
import Combine

class FFContent: Content {
    var size: simd_int2 = .zero
    var textures: (MTLTexture,MTLTexture,MTLTexture)?
    var formatContext: UnsafeMutablePointer<AVFormatContext>!
    var codecContextMap = [Int:UnsafeMutablePointer<AVCodecContext>]() // Stream Index -> Decoder
    var queuesMap = [Int:[FFFrame]]() // Stream Index -> Decoded frames
    var loop = false
    var mute = false
    var volume: Float {
        get {
            audiblePlayer?.mixerNode?.volume ?? 0
        }
        set {
            audiblePlayer?.mixerNode?.volume = newValue
        }
    }
    var position: Float {
        get {
            let elapsed = CACurrentMediaTime() - startTime
            let q = av_make_q(Int32(formatContext.pointee.duration), AV_TIME_BASE)
            let dur = av_q2d(q)
            return Float(elapsed / dur)
        }
        set {
            seek(to: newValue)
        }
    }

    deinit {
        avformat_close_input(&formatContext)
    }

    convenience init(url: String, loop: Bool?, mute: Bool?) throws {
        guard let url = URL(string: url) else {
            throw Fehler.URLWithString(string: url)
        }
        try self.init(url: url)
        self.loop = loop == true
        self.mute = mute == true
    }

    init(url: URL) throws {
        print("avformat_open_input", url.path(percentEncoded: false))
        guard 0 == avformat_open_input(&formatContext, url.path(percentEncoded: false), nil, nil) else {
            throw Fehler.avformat_open_input
        }
        avformat_find_stream_info(formatContext, nil)
        av_dump_format(formatContext, 0, url.absoluteString, 0)

        func makeDecoder(_ stream: UnsafeMutablePointer<AVStream>) throws -> UnsafeMutablePointer<AVCodecContext> {
            let params = stream.pointee.codecpar!
            let codec = avcodec_find_decoder(params.pointee.codec_id)
            let codecContext = avcodec_alloc_context3(codec)!
            codecContext.pointee.thread_count = 8
            avcodec_parameters_to_context(codecContext, params)
            guard 0 == avcodec_open2(codecContext, codec, nil) else {
                throw Fehler.avcodec_open2
            }
//            print(codecContext.pointee.sample_aspect_ratio.num)
//            print(codecContext.pointee.sample_aspect_ratio.den)
            return codecContext
        }

        try [AVMEDIA_TYPE_VIDEO, AVMEDIA_TYPE_AUDIO].forEach { mediaType in
            let streamIndex = av_find_best_stream(formatContext, mediaType, -1, -1, nil, 0)
            guard streamIndex > -1 else {
                return
            }
            let decoder = try makeDecoder(formatContext.pointee.streams[Int(streamIndex)]!)
            codecContextMap[Int(streamIndex)] = decoder
            queuesMap[Int(streamIndex)] = [FFFrame]()
        }
    }

    var startTime: CFTimeInterval = 0
    var stopTime: CFTimeInterval = 0

    fileprivate var token: AnyCancellable?
    func start() {
        startTime = CACurrentMediaTime() - stopTime
        token = engine.contentTick.sink { [weak self] in
            if let this = self {
                Task {
                    this.step()
                }
            }
        }
    }

    func stop() {
        token = nil
        stopTime = CACurrentMediaTime() - startTime
    }

    func seek(to position: Float) {
//        if semaphore.wait(timeout: .distantFuture) == .timedOut { return }
//        defer { semaphore.signal() }
        let timestamp = Int64(Float(formatContext.pointee.duration) * position)
        av_seek_frame(formatContext, -1, timestamp, 0)
        codecContextMap.forEach { key, val in
            avcodec_flush_buffers(val)
        }
        let q = av_make_q(Int32(formatContext.pointee.duration), AV_TIME_BASE)
        let d = av_q2d(q)
        startTime = CACurrentMediaTime() - d * Double(position)
        queuesMap.keys.forEach { queuesMap[$0] = [FFFrame]() }
    }

    let semaphore = DispatchSemaphore(value: 1)
    func step() {
        if semaphore.wait(timeout: .now()) == .timedOut { return }
        defer { semaphore.signal() }

        let elapsed = CACurrentMediaTime() - startTime

        /**
         * while any queue is empty
         * 1) receive frames from decoders and put them into the map
         * 2) read a packet from input and send it to the corresponding decoder
         * 3) leave loop when no packet could be read
         */
        while queuesMap.reduce(false, { partialResult, element in partialResult || element.value.isEmpty }) == true {
            for (key, val) in codecContextMap {
                let s = FFFrame()
                if 0 == avcodec_receive_frame(val, s.frame) {
                    let stream = formatContext.pointee.streams[key]!
                    s.codec_type = stream.pointee.codecpar.pointee.codec_type
                    s.pts = av_q2d(stream.pointee.time_base) * Double(s.frame.pointee.best_effort_timestamp)
//                    print("s.pts=\(s.pts)")
                    queuesMap[key]!.append(s)
                }
            }
            var packet = av_packet_alloc()
            defer { av_packet_free(&packet) }
            let res = av_read_frame(formatContext, packet)
            if 0 == res {
                if let entry = codecContextMap.first(where: { key, val in key == Int(packet!.pointee.stream_index) }) {
                    avcodec_send_packet(entry.value, packet)
                }
            }
            else {
                if res == -541478725, loop { // EOF
                    seek(to: 0)
                }
                print("av_read_frame", res)
                break
            }
        }

        /**
         * publish samples when presentation time is reached
         */
        queuesMap.keys.forEach { key in
            let startTime = Double(formatContext.pointee.start_time) / Double(AV_TIME_BASE)
            while let sample = queuesMap[key]!.first, elapsed + startTime >= sample.pts {
                publish(sample)
                queuesMap[key]!.removeFirst()
            }
        }
    }

    fileprivate func publish(_ sample: FFFrame) {
        switch sample.codec_type {
        case AVMEDIA_TYPE_AUDIO:
            publishAudible(sample)
        case AVMEDIA_TYPE_VIDEO:
            publishVisual(sample)
        default:
            break
        }
    }

    var audiblePlayer: AudiblePlayer? // lazy init
    var converter: FFConverter? // lazy init

    func publishAudible(_ sample: FFFrame) {
        if mute { return }
        if converter == nil {
            converter = try? FFConverter(sample)
        }
        guard let converter = converter else {
            return
        }
        if audiblePlayer == nil {
            audiblePlayer = AudiblePlayer()
        }
        let converted = converter.convert(sample)
        audiblePlayer?.receive(converted)
    }

    func publishVisual(_ sample: FFFrame) {

        let lumaWidth = Int(sample.frame.pointee.width)
        let lumaHeight = Int(sample.frame.pointee.height)

        var chromaWidth = Int(sample.frame.pointee.width)
        var chromaHeight = Int(sample.frame.pointee.height)

        let pixelFormat: MTLPixelFormat = .r8Unorm

        switch sample.frame.pointee.format {
        case AV_PIX_FMT_YUV420P.rawValue:
            chromaWidth = lumaWidth / 2
            chromaHeight = lumaHeight / 2
        case AV_PIX_FMT_YUV422P.rawValue:
            chromaWidth = lumaWidth / 2
        case AV_PIX_FMT_YUV444P.rawValue:
            break
        default:
            print("unsupported pixel format", sample.frame.pointee.format)
            return
        }

        if textures == nil {
            let lumaTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: lumaWidth, height: lumaHeight, mipmapped: false)
            lumaTextureDescriptor.usage = [.shaderRead]
            lumaTextureDescriptor.storageMode = .shared
            guard let yTexture = engine.device.makeTexture(descriptor: lumaTextureDescriptor) else {
                print("error", Fehler.makeTexture)
                return
            }

            let chromaTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: chromaWidth, height: chromaHeight, mipmapped: false)
            chromaTextureDescriptor.usage = [.shaderRead]
            chromaTextureDescriptor.storageMode = .shared
            guard let uTexture = engine.device.makeTexture(descriptor: chromaTextureDescriptor) else {
                print("error", Fehler.makeTexture)
                return
            }
            guard let vTexture = engine.device.makeTexture(descriptor: chromaTextureDescriptor) else {
                print("error", Fehler.makeTexture)
                return
            }
            textures = (yTexture, uTexture, vTexture)
            size = simd_int2(Int32(lumaWidth), Int32(lumaHeight))
        }

        if let textures = textures {
            textures.0.replace(region: .init(origin: .init(x: 0, y: 0, z: 0), size: .init(width: lumaWidth, height: lumaHeight, depth: 1)), mipmapLevel: 0, withBytes: sample.frame.pointee.data.0!, bytesPerRow: Int(sample.frame.pointee.linesize.0))
            textures.1.replace(region: .init(origin: .init(x: 0, y: 0, z: 0), size: .init(width: chromaWidth, height: chromaHeight, depth: 1)), mipmapLevel: 0, withBytes: sample.frame.pointee.data.1!, bytesPerRow: Int(sample.frame.pointee.linesize.1))
            textures.2.replace(region: .init(origin: .init(x: 0, y: 0, z: 0), size: .init(width: chromaWidth, height: chromaHeight, depth: 1)), mipmapLevel: 0, withBytes: sample.frame.pointee.data.2!, bytesPerRow: Int(sample.frame.pointee.linesize.2))
        }
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        if let textures = textures {
            renderEncoder.setFragmentTexture(textures.0, index: TextureIndex.one.rawValue)
            renderEncoder.setFragmentTexture(textures.1, index: TextureIndex.two.rawValue)
            renderEncoder.setFragmentTexture(textures.2, index: TextureIndex.three.rawValue)
            renderEncoder.setRenderPipelineState(engine.pipelineContentYUVTriplanar)
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

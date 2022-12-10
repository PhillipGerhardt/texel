//
//  VisionDetector.swift
//  Texel
//
//  Created by Phillip Gerhardt on 10.12.22.
//

import Vision
import AVFoundation
import Combine

enum DetectionType: String {
    case face
    case humanBody
    case humanHand
}

class SampleBufferReader {

    let visualOutputSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_422YpCbCr8]
    let asset: AVAsset
    var reader: AssetReader
    var startTime: CFTimeInterval = 0
    var visualPeek: CMSampleBuffer?

    init(url: URL) throws {
        asset = AVAsset(url: url)
        reader = try AssetReader(asset: asset, visualOutputSettings: visualOutputSettings, audibleOutputSettings: nil, timeRange: nil)
        reader.startReading()
    }

    deinit {
        print("SampleBufferReader deinit")
    }

    func step() -> CMSampleBuffer? {
        let elapsed = CACurrentMediaTime() - startTime
        var result: CMSampleBuffer?
        if let visualOutput = reader.visualOutput {
            while true {
                if visualPeek == nil {
                    visualPeek = visualOutput.copyNextSampleBuffer()
                }
                if let current = visualPeek, elapsed > current.presentationTimeStamp.seconds {
                    result = current
                    self.visualPeek = nil
                } else {
                    break
                }
            }
        }
        if visualPeek == nil, reader.status == .completed {
            restart()
        }
        return result
    }

    func restart() {
        if let reader = try? AssetReader(asset: asset, visualOutputSettings: visualOutputSettings, audibleOutputSettings: nil, timeRange: nil) {
            reader.startReading()
            startTime = CACurrentMediaTime()
            self.reader = reader
        }
    }

}

class VisionDetectorContent: Content {

    var size: simd_int2
    var texture: MTLTexture

    let commandQueue: MTLCommandQueue
    var renderPassDescriptor = MTLRenderPassDescriptor()
    var uniforms = Uniforms()
    let pipeline: MTLRenderPipelineState

    let reader: SampleBufferReader

    var detectionRequest: VNImageBasedRequest?
    var quads = [(Float, Float, Float, Float)]()

    let detectionType: DetectionType

    convenience init(path: String, type: DetectionType, size: simd_int2) throws {
        try self.init(url: URL(fileURLWithPath: path), type: type, size: size)
    }

    init(url: URL, type: DetectionType, size: simd_int2) throws {
        self.size = size
        self.detectionType = type

        guard let commandQueue = engine.device.makeCommandQueue() else {
            throw Fehler.makeCommandQueue
        }
        self.commandQueue = commandQueue

        reader = try SampleBufferReader(url: url)

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(size.x), height: Int(size.y), mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .renderTarget]
        guard let texture = engine.device.makeTexture(descriptor: textureDescriptor) else {
            throw Fehler.makeTexture
        }
        self.texture = texture

        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        uniforms.viewMatrix = matrix_identity_float4x4
        uniforms.projectionMatrix = matrix_ortho_right_hand(left: 0, right: Float(size.x), bottom: 0, top: Float(size.y), nearZ: -1, farZ: 1)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = engine.vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.label = "Vision"
        pipelineDescriptor.vertexFunction = engine.library.makeFunction(name: "vertexLayer")
        pipelineDescriptor.fragmentFunction = engine.library.makeFunction(name: "fragmentLayer")
        pipeline = try engine.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    deinit {
        print("VisionDetector deinit")
    }

    var token: AnyCancellable?
    func start() {
        reader.startTime = CACurrentMediaTime()
        token = engine.contentTick.sink { [weak self] in
            if let self {
                Task {
                    self.step()
                }
            }
        }
    }

    let semaphore = DispatchSemaphore(value: 1)
    func step() {
        if semaphore.wait(timeout: .now()) == .timedOut { return }
        defer { semaphore.signal() }

        guard let sampleBuffer = reader.step() else { return }

        if detectionRequest == nil {

            let completionHandler: VNRequestCompletionHandler = { [weak self] (request: VNRequest, error: Error?) in
                if error != nil {
                    print("Detection error: \(String(describing: error)).")
                }
                guard let results = request.results else { return }
                if let self {
                    self.update(results: results)
                }
            }

            switch detectionType {
            case .face:
                detectionRequest = VNDetectFaceRectanglesRequest(completionHandler: completionHandler)
            case .humanBody:
                detectionRequest = VNDetectHumanBodyPoseRequest(completionHandler: completionHandler)
            case .humanHand:
                detectionRequest = VNDetectHumanHandPoseRequest(completionHandler: completionHandler)
            }

        }
        if let detectionRequest = detectionRequest {
            var requests = [VNRequest]()
            requests.append(detectionRequest)
            let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
            try? requestHandler.perform(requests)
        }
    }

    func update(results: [VNObservation]) {
        var quads = [(Float, Float, Float, Float)]()

        for result in results {
            if let result = result as? VNHumanBodyPoseObservation {
                let points = result.availableJointNames.compactMap{ try? result.recognizedPoint($0) }.filter{ $0.confidence > 0.1 }
                points.forEach {
                    let w: Float = 0.01 * Float(size.x)
                    let h: Float = 0.01 * Float(size.y)
                    let x = Float($0.x) * Float(size.x)
                    let y = Float($0.y) * Float(size.y)
                    quads.append((x,y,w,h))
                }
            }
            if let result = result as? VNFaceObservation {
                let w = Float(result.boundingBox.size.width)  * Float(size.x)
                let h = Float(result.boundingBox.size.height) * Float(size.y)
                let x = Float(result.boundingBox.minX)    * Float(size.x)
                let y = Float(result.boundingBox.minY)    * Float(size.y)
                quads.append((x,y,w,h))
            }
            if let result = result as? VNHumanHandPoseObservation {
                let points = result.availableJointNames.compactMap{ try? result.recognizedPoint($0) }.filter{ $0.confidence > 0.1 }
                points.forEach {
                    let w: Float = 0.01  * Float(size.x)
                    let h: Float = 0.01  * Float(size.y)
                    let x = Float($0.x) * Float(size.x)
                    let y = Float($0.y) * Float(size.y)
                    quads.append((x,y,w,h))
                }
            }

        }

        self.quads = quads
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.setTriangleFillMode(.lines)

                renderEncoder.setRenderPipelineState(pipeline)
                renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: BufferIndex.uniforms.rawValue)
                renderEncoder.setVertexBuffer(engine.verticesBuffer, offset:0, index: BufferIndex.vertices.rawValue)
                for (x,y,w,h) in self.quads {
                    let transform = matrix_identity_float4x4.translated(simd_float2(x,y))
                    let color: simd_float4 = .one
                    var model = Model(matrix: transform, color: color, size: simd_float2(w,h))
                    renderEncoder.setVertexBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                    renderEncoder.setFragmentBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

                }
                renderEncoder.endEncoding()
            }
            commandBuffer.commit()
        }
        renderEncoder.setFragmentTexture(texture, index: TextureIndex.one.rawValue)
        renderEncoder.setRenderPipelineState(engine.pipelineContent)
        return true
    }

}

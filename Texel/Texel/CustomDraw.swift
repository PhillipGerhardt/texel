//
//  CustomDraw.swift
//  Texel
//
//  Created by Phillip Gerhardt on 2024.09.28.
//

import Metal
import QuartzCore


class CustomDrawContent: Content {
    var size: simd_int2 = .one

    let numSamples: Int
    let speed: Float
    let pointSize: Float

    let samplesBuffer: MTLBuffer
    let samples: UnsafeMutablePointer<Float>

    let begin = CACurrentMediaTime()

    init(numSamples: Int, speed: Float, pointSize: Float) throws {
        self.numSamples = numSamples
        self.speed = speed
        self.pointSize = pointSize

        let alignedSampleSize = (MemoryLayout<Float>.size * numSamples + 0xFF) & -0x100

        guard let samplesBuffer = engine.device.makeBuffer(length: alignedSampleSize, options: [MTLResourceOptions.storageModeShared]) else { throw Fehler.makeBuffer }
        samplesBuffer.label = "samplesBuffer"
        self.samplesBuffer = samplesBuffer
        self.samples = UnsafeMutableRawPointer(self.samplesBuffer.contents()).bindMemory(to:Float.self, capacity: numSamples)
    }

    deinit {
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        let elapsed = CACurrentMediaTime() - begin
        for i in 0..<numSamples {
            let x = (Float(i) + Float(elapsed)) * speed
            samples[i] = Float(sin(x) * 0.5 + 0.5)
//            samples[i] = Float.random(in: 0...1)
        }
        return true
    }

    var drawCall: ((any MTLRenderCommandEncoder) -> Void)? {
        return { [weak self] renderEncoder in
            guard let self else { return }

            renderEncoder.setRenderPipelineState(engine.pipelineCustomDraw)
            var model = ModelCustomDraw(numSamples: Int32(numSamples), pointSize: pointSize)
            renderEncoder.setVertexBytes(&model, length: MemoryLayout<ModelCustomDraw>.size, index: BufferIndex.modelCustomDraw.rawValue)
            renderEncoder.setVertexBuffer(samplesBuffer, offset: 0, index: BufferIndex.samples.rawValue)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: numSamples)
        }
    }
}

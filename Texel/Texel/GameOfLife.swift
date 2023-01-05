//
//  GameOfLife.swift
//  Texel
//
//  Created by Phillip Gerhardt on 18.12.22.
//

import Metal
import AppKit

class GameOfLifeContent: Content {
    var size: simd_int2 = .zero

    var uniforms = Uniforms()
    var textures: (MTLTexture, MTLTexture)
    let renderPassDescriptor = MTLRenderPassDescriptor()
    let pipelinePaint: MTLRenderPipelineState
    let pipelineCompute: MTLComputePipelineState
    let commandQueue: MTLCommandQueue

    init(size: simd_int2) throws {
        self.size = size

        guard let commandQueue = engine.device.makeCommandQueue() else {
            throw Fehler.makeCommandQueue
        }
        self.commandQueue = commandQueue

        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        uniforms.viewMatrix = matrix_identity_float4x4
        uniforms.projectionMatrix = matrix_ortho_right_hand(left: 0, right: Float(size.x), bottom: 0, top: Float(size.y), nearZ: -1, farZ: 1)

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm , width: Int(size.x), height: Int(size.y), mipmapped: false)
        textureDescriptor.usage = [.shaderWrite, .shaderRead, .renderTarget]
        textures = (engine.device.makeTexture(descriptor: textureDescriptor)!,
                    engine.device.makeTexture(descriptor: textureDescriptor)!)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = engine.vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .r8Unorm
        pipelineDescriptor.label = "Paint"
        pipelineDescriptor.vertexFunction = engine.library.makeFunction(name: "vertexLayer")
        pipelineDescriptor.fragmentFunction = engine.library.makeFunction(name: "fragmentLayer")
        pipelinePaint = try engine.device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        let computeFunction = engine.library.makeFunction(name: "gameOfLifeGeneration")!
        pipelineCompute = try engine.device.makeComputePipelineState(function: computeFunction)
    }

    func onEvent(_ event: NSEvent, at point: simd_float2) {
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            renderPassDescriptor.colorAttachments[0].texture = textures.1
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.setRenderPipelineState(pipelinePaint)
                renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: BufferIndex.uniforms.rawValue)
                renderEncoder.setVertexBuffer(engine.verticesBuffer, offset:0, index: BufferIndex.vertices.rawValue)
                let transform = matrix_identity_float4x4.translated(point * size.float2)
                var model = Model(matrix: transform, color: .one, size: simd_float2(5, 5))
                renderEncoder.setVertexBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.setFragmentBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
                renderEncoder.endEncoding()
            }
            commandBuffer.commit()
        }
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        textures = (textures.1, textures.0)

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
                computeEncoder.setComputePipelineState(pipelineCompute)
                computeEncoder.setTexture(textures.0, index: TextureIndex.one.rawValue)
                computeEncoder.setTexture(textures.1, index: TextureIndex.two.rawValue)
                let threadWidth = pipelineCompute.threadExecutionWidth
                let threadHeight = pipelineCompute.maxTotalThreadsPerThreadgroup / threadWidth
                let threadsPerThreadgroup = MTLSizeMake(threadWidth, threadHeight, 1)
                let textureSize = MTLSize(width: textures.0.width, height: textures.0.height, depth: 1)
                computeEncoder.dispatchThreads(textureSize, threadsPerThreadgroup: threadsPerThreadgroup)
                computeEncoder.endEncoding()
            }
            commandBuffer.commit()
        }

        renderEncoder.setFragmentTexture(textures.0, index: TextureIndex.one.rawValue)
        renderEncoder.setRenderPipelineState(engine.pipelineContent)
        return true
    }
}

//
//  Renderer.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

/**
 * Adopted from apple samples
 */

import Metal
import MetalKit
import simd
import Combine

/*
 * Recursively render the scene's layer tree to the metal view
 */
class Renderer: NSObject, MTKViewDelegate {

    let mtkView: MTKView
    let commandQueue: MTLCommandQueue
    let semaphore = DispatchSemaphore(value: 1)

    required init?(metalKitView: MTKView) {
        mtkView = metalKitView
        commandQueue = engine.device.makeCommandQueue()!
//        (metalKitView.layer as? CAMetalLayer)?.displaySyncEnabled = false
        (metalKitView.layer as? CAMetalLayer)?.wantsExtendedDynamicRangeContent = true
        metalKitView.depthStencilPixelFormat = engine.depthStencilPixelFormat
        metalKitView.colorPixelFormat = engine.colorPixelFormat
        metalKitView.sampleCount = engine.sampleCount
        (metalKitView.layer as? CAMetalLayer)?.colorspace = CGColorSpace(name: CGColorSpace.extendedDisplayP3)
    }

    var token: AnyCancellable?
    func start() {
        token = engine.displayTick
            .sink(receiveValue: {
                self.mtkView.draw()
            })
    }

    func stop() {
        token = nil
    }

    var stencilReferenceValue: UInt32 = 0

     func draw(in view: MTKView) {
        /// Per frame updates here
         if semaphore.wait(timeout: .now()) == .timedOut { return }
         if let commandBuffer = commandQueue.makeCommandBuffer() {
             commandBuffer.addCompletedHandler { [self](_ commandBuffer) in
                 semaphore.signal()
             }

             /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
             /// holding onto the drawable and blocking the display pipeline any longer than necessary
             if let renderPassDescriptor = view.currentRenderPassDescriptor {

                 stencilReferenceValue = 0

                 renderPassDescriptor.colorAttachments[0].loadAction = .clear
                 renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(Double(engine.clearColor.x), Double(engine.clearColor.y), Double(engine.clearColor.z), Double(engine.clearColor.w))

                 /// Final pass rendering code here
                 if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                     renderEncoder.label = "Primary Render Encoder"

                     renderEncoder.setStencilReferenceValue(stencilReferenceValue)
                     renderEncoder.setDepthStencilState(engine.depthStencilTestState)

                     renderEncoder.setVertexBuffer(engine.uniformsBuffer, offset:0, index: BufferIndex.uniforms.rawValue)
                     renderEncoder.setVertexBuffer(engine.verticesBuffer, offset:0, index: BufferIndex.vertices.rawValue)

                     let layers = engine.scene.layers // this is a copy of the set layers (it's a copy on write)
                     render(layers, transform: matrix_identity_float4x4, renderEncoder: renderEncoder)

                     renderEncoder.endEncoding()
                     if let drawable = view.currentDrawable {
                         commandBuffer.present(drawable)
                     }
                 }
             }
             commandBuffer.commit()
         }
     }

    func render(_ layers: [Layer], transform: simd_float4x4, renderEncoder: MTLRenderCommandEncoder) {
        for layer in layers {

            /** Make a copy. layer.clip can change while rendering the layer tree.
                That would result in an exception when decrementing the stencil value */
            let clip = layer.clip

            /** Write stencil reference value */
            func stencil(_ depthStencilState: MTLDepthStencilState) {
                renderEncoder.setDepthStencilState(depthStencilState)
                renderEncoder.setRenderPipelineState(engine.pipelineStencil)
                var model = Model(matrix: transform * layer.transform, color: layer.color, size: layer.size)
                renderEncoder.setVertexBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.setFragmentBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            }

            if clip {
                stencil(engine.depthStencilIncrementState)
                stencilReferenceValue += 1
                renderEncoder.setStencilReferenceValue(stencilReferenceValue)
                renderEncoder.setDepthStencilState(engine.depthStencilTestState)
            }

            if layer.draw {
                renderEncoder.setRenderPipelineState(engine.pipelineLayer)
                var model = Model(matrix: transform * layer.transform, color: layer.color, size: layer.size)
                renderEncoder.setVertexBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.setFragmentBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            }

            if let content = layer.content, content.configure(renderEncoder) {
                var model = Model(matrix: transform * layer.contentTransform, color: layer.contentColor, size: layer.contentSize)
                renderEncoder.setVertexBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.setFragmentBytes(&model, length: MemoryLayout<Model>.size, index: BufferIndex.model.rawValue)
                renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            }

            let children = layer.children // copy on write
            render(children, transform: transform * layer.childTransform, renderEncoder: renderEncoder)

            if clip {
                stencil(engine.depthStencilDecrementState)
                stencilReferenceValue -= 1
                renderEncoder.setStencilReferenceValue(stencilReferenceValue)
                renderEncoder.setDepthStencilState(engine.depthStencilTestState)
            }

        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        /// Respond to drawable size or orientation changes here
        let w = Float(size.width)
        let h = Float(size.height)
        let projectionMatrix = matrix_ortho_right_hand(left: 0, right: w, bottom: 0, top: h, nearZ: -1, farZ: 1)
        let viewMatrix = matrix_identity_float4x4
//        let projectionMatrix = matrix_perspective_right_hand(fovyRadians: Float.pi/2, aspectRatio: w/h, nearZ: 1, farZ: h)
//        let viewMatrix = matrix_identity_float4x4.translated(simd_float3(-w/2,-h/2,-h/2))
        engine.scene.size = simd_float2(w, h)
        engine.scene.projection = projectionMatrix
        engine.uniforms[0].projectionMatrix = projectionMatrix
        engine.uniforms[0].viewMatrix = viewMatrix
    }
}

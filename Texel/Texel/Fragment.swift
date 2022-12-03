//
//  Fragment.swift
//  Texel
//
//  Created by Phillip Gerhardt on 03.12.22.
//

import MetalKit

class FragmentContent: Content {
    var size: simd_int2 = .one
    var pipeline: MTLRenderPipelineState?
    var source: String = "" { didSet { compile() } }

    var point = simd_float2(repeating: 0.5)

    var textureOne: TextureContent?
    var textureTwo: TextureContent?
    var textureThree: TextureContent?
    var textureFour: TextureContent?

    init() {
    }

    func onEvent(_ event: NSEvent, at point: simd_float2) {
        self.point = point
    }

    func compile() {
        do {
            let library = try engine.device.makeLibrary(source: source, options: nil)
            engine.pipelineDescriptor.label = "Fragment"
            engine.pipelineDescriptor.vertexFunction = engine.library.makeFunction(name: "vertexLayer")
            engine.pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentSource")
            pipeline = try engine.device.makeRenderPipelineState(descriptor: engine.pipelineDescriptor)
        }
        catch {
            pipeline = nil
            print("error", error)
        }
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        if let pipeline {
            renderEncoder.setRenderPipelineState(pipeline)
            var time = Float(CACurrentMediaTime())
            renderEncoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: BufferIndex.time.rawValue)
            renderEncoder.setFragmentBytes(&point, length: MemoryLayout<simd_float2>.size, index: BufferIndex.point.rawValue)

            if let texture = textureOne?.texture { renderEncoder.setFragmentTexture(texture, index: TextureIndex.one.rawValue) }
            if let texture = textureTwo?.texture { renderEncoder.setFragmentTexture(texture, index: TextureIndex.two.rawValue) }
            if let texture = textureThree?.texture { renderEncoder.setFragmentTexture(texture, index: TextureIndex.three.rawValue) }
            if let texture = textureFour?.texture { renderEncoder.setFragmentTexture(texture, index: TextureIndex.four.rawValue) }

            return true
        }
        return false
    }

}

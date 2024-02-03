//
//  Content.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AppKit
import simd
import Metal

/**
 * Content is put into a layer and displayed there.
 * TODO: Protocol or base class?
*/
protocol Content: AnyObject {
    var size: simd_int2 { get set }
    var volume: Float { get set }
    var position: Float { get set }
    func start() // image is a content. can it be started?
    func stop() // or stopped?
    func seek(to position: Float) -> Void
    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool
    func onEvent(_ event: NSEvent, at point: simd_float2) -> Void
}

extension Content {
    var size: simd_int2 { get {.zero} set{} }
    var volume: Float { get{0} set{} }
    var position: Float { get{0} set{} }
    func start() {}
    func stop() {}
    func seek(to position: Float) {}
    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool { false }
    func onEvent(_ event: NSEvent, at point: simd_float2) -> Void {}
}

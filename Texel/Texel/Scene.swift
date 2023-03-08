//
//  Scene.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Combine

/**
 * Thread safe list of input events
 */
actor EventsQueue {
    var events = [Event]()

    func append(_ event: Event) {
        events.append(event)
    }

    func pending() async -> [Event] {
        defer { events.removeAll() }
        return events
    }
}

/**
 * The scene is just a collection of layers that are drawn.
 */
class Scene {

    let events = EventsQueue()
    var size = simd_float2.one { didSet { print("Scene.size.didSet", size) } }
    var projection = matrix_identity_float4x4 { didSet { print("Scene.projection.didSet", projection) } }
    var layers = [Layer]()

    init() {
    }

    func barycentric(size: simd_float2, transform: simd_float4x4) -> (simd_float3x3, simd_float3x3) {
        let s = simd_float4(size.x, size.y, 0, 1)
        let ll = projection * transform * (simd_float4(0,0,0,1) * s)
        let lr = projection * transform * (simd_float4(1,0,0,1) * s)
        let ul = projection * transform * (simd_float4(0,1,0,1) * s)
        let ur = projection * transform * (simd_float4(1,1,0,1) * s)
        let a = simd_float3(ul.x, ul.y, ul.z)
        let b = simd_float3(ur.x, ur.y, ur.z)
        let c = simd_float3(ll.x, ll.y, ll.z)
        let d = simd_float3(lr.x, lr.y, lr.z)
        let bary1 = simd_inverse( simd_float3x3([a,b,c]) )
        let bary2 = simd_inverse( simd_float3x3([c,b,d]) )
        return (bary1, bary2)
    }

    func layer(at: simd_float2) -> Layer? {
        let pos = projection * simd_float4(at.x * size.x, at.y * size.y, 0, 1)
        var hitLayer: Layer?

        func probe(size: simd_float2, transform: simd_float4x4) -> simd_float2? {
            let bary = barycentric(size: size, transform: transform)
            // Weight for the triangles.
            let w1 = bary.0 * simd_float3(pos.x, pos.y, pos.z)
            let w2 = bary.1 * simd_float3(pos.x, pos.y, pos.z)
            // Hit any of the triangles?
            if w1.min() >= 0 || w2.min() >= 0 {
                let coordinates = w1.x * simd_float2(0, 1) + w1.y * simd_float2(1, 1) + w1.z * simd_float2(0, 0)
                return coordinates
            }
            return nil
        }

        func probe(_ layers: [Layer], transform: simd_float4x4) {
            for layer in layers {
                if let _ = probe(size: layer.size, transform: transform * layer.transform) {
                    hitLayer = layer
                }
                probe(layer.sublayers, transform: transform * layer.childTransform)
            }
        }

        probe(layers, transform: matrix_identity_float4x4)
        return hitLayer
    }

    func interpretEvents() async {
        let evts = await events.pending()
        for evt in evts {

            NodeInterpretEvent(evt)

            let pos = projection * simd_float4(evt.position.x * size.x, evt.position.y * size.y, 0, 1)
//            print("phase", evt.event.phase)
//            print("position", evt.position)
//            print("src", src)

            var hitLayer: Layer?
            var hitLayerTransform: simd_float4x4?

            var hitContent: Content?
            var hitCoordinates: simd_float2?

            func probe(size: simd_float2, transform: simd_float4x4) -> simd_float2? {
                let bary = barycentric(size: size, transform: transform)
                // Weight for the triangles.
                let w1 = bary.0 * simd_float3(pos.x, pos.y, pos.z)
                let w2 = bary.1 * simd_float3(pos.x, pos.y, pos.z)
                // Hit any of the triangles?
                if w1.min() > 0 || w2.min() > 0 {
                    let coordinates = w1.x * simd_float2(0, 1) + w1.y * simd_float2(1, 1) + w1.z * simd_float2(0, 0)
                    return coordinates
                }
                return nil
            }

            func probe(_ layers: [Layer], transform: simd_float4x4) {
                for layer in layers {
                    if let _ = probe(size: layer.size, transform: transform * layer.transform) {
                        hitLayer = layer
                        hitLayerTransform = transform
                    }
                    if layer.content != nil, let coords = probe(size: layer.contentSize, transform: transform * layer.contentTransform) {
                        hitContent = layer.content
                        hitCoordinates = coords
                    }
                    probe(layer.sublayers, transform: transform * layer.childTransform)
                }
            }

            probe(layers, transform: matrix_identity_float4x4)

            if !evt.event.modifierFlags.contains([.control]) {
                if let hitContent = hitContent,
                   let hitCoordinates = hitCoordinates {
                    hitContent.onEvent(evt.event, at: hitCoordinates)
                }
            }

            if let layer = hitLayer, let layerTransform = hitLayerTransform {
                
                // drag layers around
                if evt.event.modifierFlags.contains([.control]) {
                    // set random color to layer
                    if evt.event.type == .leftMouseDown {
                        let r = Float.random(in: 0...1)
                        let g = Float.random(in: 0...1)
                        let b = Float.random(in: 0...1)
                        let dst = simd_float4(r, g, b, 1)
                        layer.color = dst
                    }
                    // drag layer
                    if evt.event.type == .rightMouseDragged {
                        var p = layer.position
                        var d = simd_float4(evt.delta, 1)
                        let q = simd_quatf(layerTransform)
                        let m = simd_matrix4x4(q)
                        d = m * d
                        p.x += d.x
                        p.y -= d.y
                        layer.position = p
                    }
                    // rotate layer
                    if evt.event.type == .otherMouseDragged {
                        var a = layer.orientation.angle
                        a -= evt.delta.x / 100
                        while a > Float.pi * 2 {
                            a -= Float.pi * 2
                        }
                        while a < 0 {
                            a += Float.pi * 2
                        }
                        layer.orientation = simd_quatf(angle: a, axis: simd_float3(0, 0, 1))
                    }
                    // resize layer
                    if evt.event.type == .scrollWheel {
                        var size = layer.size
                        let aspect = size.x / size.y
                        let dt = evt.delta.y * 5
                        size.x += dt * aspect
                        size.y += dt
                        layer.size = size
                    }
                }
            }

        }
    }

}

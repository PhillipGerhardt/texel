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
class EventsQueue {
    private var events = [Event]()
    private let queue = DispatchQueue.main

    func append(_ event: Event) {
        queue.async {
            self.events.append(event)
        }
    }

    func pending() -> [Event] {
        return  queue.sync {
            let pendingEvents = self.events
            self.events.removeAll()
            return pendingEvents
        }
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

    func barycentric(a: simd_float2, b: simd_float2, c: simd_float2, p: simd_float2) -> simd_float3 {
        let x1 = a.x
        let y1 = a.y
        let x2 = b.x
        let y2 = b.y
        let x3 = c.x
        let y3 = c.y
        let xs = p.x
        let ys = p.y
        let m1 = ((x2-xs)*(y3-ys)-(x3-xs)*(y2-ys)) / ((x2-x1)*(y3-y2)-(y2-y1)*(x3-x2))
        let m2 = ((x3-xs)*(y1-ys)-(x1-xs)*(y3-ys)) / ((x2-x1)*(y3-y2)-(y2-y1)*(x3-x2))
        let m3 = ((x1-xs)*(y2-ys)-(x2-xs)*(y1-ys)) / ((x2-x1)*(y3-y2)-(y2-y1)*(x3-x2))
        return simd_float3(m1,m2,m3)
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

    func isVisible(layer: Layer, with transform: simd_float4x4? = nil) -> Bool {
        var layerTransform = transform ?? self.transform(ofLayer: layer)
        guard let layerTransform else { return false }

        let layerSize = simd_float4(layer.size.x, layer.size.y, 0, 1)
        let ll = (layerTransform * (simd_float4(0,0,0,1) * layerSize)).xy
        let lr = (layerTransform * (simd_float4(1,0,0,1) * layerSize)).xy
        let ul = (layerTransform * (simd_float4(0,1,0,1) * layerSize)).xy
        let ur = (layerTransform * (simd_float4(1,1,0,1) * layerSize)).xy
        let cc = [ll,lr,ul,ur].reduce(simd_float2()) { $0 + $1 } / 4.0

        let a = simd_float2(0, 0) * size
        let b = simd_float2(1, 0) * size
        let c = simd_float2(0, 1) * size
        let d = simd_float2(1, 1) * size

        for p in [ll,lr,ul,ur,cc] {
            for (a,b,c) in [(a,b,c), (b,c,d)] {
                let w = barycentric(a: a, b: b, c: c, p: p)
                if w.min() >= 0 {
                    return true
                }
            }
        }
        for p in [a,b,c,d] {
            for (a,b,c) in [(ll,lr,ul), (lr,ul,ur)] {
                let w = barycentric(a: a, b: b, c: c, p: p)
                if w.min() >= 0 {
                    return true
                }
            }
        }
        return false
    }

    func layer(at: simd_float2) -> Layer? {
        print("at", at)
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
                probe(layer.children, transform: transform * layer.childTransform)
            }
        }

        probe(layers, transform: matrix_identity_float4x4)
        return hitLayer
    }

    func transform(ofLayer key: Layer) -> simd_float4x4? {
        func probe(_ layers: [Layer], transform: simd_float4x4) -> simd_float4x4? {
            for layer in layers {
                if key === layer {
                    return transform * layer.transform
                }
                if let transform = probe(layer.children, transform: transform * layer.childTransform) {
                    return transform
                }
            }
            return nil
        }
        let transform = probe(layers, transform: matrix_identity_float4x4)
        return transform
    }

    func interpretEvents() {
        let evts = events.pending()
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
                    if !layer.interactive { continue }
                    if let _ = probe(size: layer.size, transform: transform * layer.transform) {
                        hitLayer = layer
                        hitLayerTransform = transform
                    }
                    if layer.content != nil, let coords = probe(size: layer.contentSize, transform: transform * layer.contentTransform) {
                        hitContent = layer.content
                        hitCoordinates = coords
                    }
                    probe(layer.children, transform: transform * layer.childTransform)
                }
            }

            probe(layers, transform: matrix_identity_float4x4)

            if !evt.event.modifierFlags.contains(.control), !evt.event.modifierFlags.contains(.option) {
                if let hitContent = hitContent,
                   let hitCoordinates = hitCoordinates {
                    hitContent.onEvent(evt.event, at: hitCoordinates)
                }
            }

            if let layer = hitLayer, let layerTransform = hitLayerTransform {
                if evt.event.modifierFlags.contains([.option]) {
                    // set random color to layer
                    if evt.event.type == .leftMouseDown {
                        let r = Float.random(in: 0...1)
                        let g = Float.random(in: 0...1)
                        let b = Float.random(in: 0...1)
                        let dst = simd_float4(r, g, b, 1)
                        layer.color = dst
                    }
                }
                if evt.event.modifierFlags.contains([.control]) {
                    // bring to front
                    if evt.event.type == .rightMouseDown {
                        layers.removeAll { $0 === layer }
                        layers.append(layer)
                    }
                    // drag layer
                    if evt.event.type == .leftMouseDragged {
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

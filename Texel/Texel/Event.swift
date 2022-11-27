//
//  Event.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

@preconcurrency import AppKit.NSEvent
import simd

final class Event: CustomStringConvertible, Sendable {

    let point: CGPoint
    let event: NSEvent
    let scale: CGFloat

    init(point: CGPoint, with event: NSEvent, scale: CGFloat) {
        self.point = point
        self.event = event
        self.scale = scale
    }

    var position: simd_float3 {
        get {
            simd_float3(x: Float(point.x), y: Float(point.y), z: 0)
        }
    }

    var delta: simd_float3 {
        get {
            simd_float3(x: Float(event.deltaX * scale), y: Float(event.deltaY * scale), z: 0)
        }
    }

    var description: String {
        get {
            "Event: event=\(event) point=\(point)"
        }
    }

}


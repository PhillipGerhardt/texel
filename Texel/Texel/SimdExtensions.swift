//
//  SimdExtensions.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import simd
import Metal

extension simd_int2 {

    var rect: CGRect {
        CGRect(x: 0, y: 0, width: CGFloat(self.x), height: CGFloat(self.y))
    }

    var region: MTLRegion {
        MTLRegion(origin: .init(x: 0, y: 0, z: 0), size: .init(width: Int(self.x), height: Int(self.y), depth: 1))
    }

    var float2: simd_float2 {
        simd_float2(Float(x), Float(y))
    }

}

extension simd_float3 {

    static func -(lhs: simd_float3, rhs: simd_float2) -> simd_float3 {
        simd_float3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z)
    }

}

extension simd_float4 {

    var xy: simd_float2 {
        simd_float2(self.x, self.y)
    }

}

extension simd_float4x4 {

    func translated(_ translation: simd_float3) -> simd_float4x4 {
        var m = self
        m.columns.3.x += translation.x
        m.columns.3.y += translation.y
        m.columns.3.z += translation.z
        return m
    }

    func translated(_ translation: simd_float2) -> simd_float4x4 {
        var m = self
        m.columns.3.x += translation.x
        m.columns.3.y += translation.y
        return m
    }

}

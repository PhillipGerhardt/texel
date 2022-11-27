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

}

extension simd_float4x4 {

    func scaled(_ scale: simd_float3) -> simd_float4x4 {
        let rows = [
            simd_float4(scale.x,      0,       0, 0),
            simd_float4(     0, scale.y,       0, 0),
            simd_float4(     0,       0, scale.z, 0),
            simd_float4(     0,       0,       0, 1)
        ]
        let m = float4x4(rows: rows)
        return m * self
    }

    func scaled(_ scale: simd_float2) -> simd_float4x4 {
        let rows = [
            simd_float4(scale.x,      0, 0, 0),
            simd_float4(     0, scale.y, 0, 0),
            simd_float4(     0,       0, 1, 0),
            simd_float4(     0,       0, 0, 1)
        ]
        let m = float4x4(rows: rows)
        return m * self
    }

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

    func translation() -> simd_float3 {
        return simd_float3(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }

    func rotation_scale() -> simd_float4x4 {
        var m = self
        m.columns.3.x = 0
        m.columns.3.y = 0
        return m
    }

}

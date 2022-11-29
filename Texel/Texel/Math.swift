//
//  Math.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import simd

public func matrix_ortho_right_hand(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let rows = [
        simd_float4(2 / (right - left),                  0,                   0, (left + right) / (left - right)),
        simd_float4(0,                  2 / (top - bottom),                   0, (top + bottom) / (bottom - top)),
        simd_float4(0,                                   0, -1 / (farZ - nearZ),          nearZ / (nearZ - farZ)),
        simd_float4(0,                                   0,                   0,                               1 )
    ]
    return float4x4(rows: rows)
}

public func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return simd_float4x4.init(columns:(
        simd_float4(xs,  0, 0,   0),
        simd_float4( 0, ys, 0,   0),
        simd_float4( 0,  0, zs, -1),
        simd_float4( 0,  0, zs * nearZ, 0)
    ))
}


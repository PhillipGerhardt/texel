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

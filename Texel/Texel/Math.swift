//
//  Math.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import simd

/**
 * Generic matrix math utility functions
 * Math from Apple samples
 */

public func matrix4x4_rotation(radians: Float, axis: simd_float3) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return simd_float4x4.init(columns:  (simd_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         simd_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         simd_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         simd_float4(                  0,                   0,                   0, 1)))
}

public func matrix4x4_translation(_ translation: simd_float3) -> matrix_float4x4 {
    return simd_float4x4.init(columns:  (simd_float4(1, 0, 0, 0),
                                         simd_float4(0, 1, 0, 0),
                                         simd_float4(0, 0, 1, 0),
                                         simd_float4(translation, 1)))
}

public func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return simd_float4x4.init(columns:  (simd_float4(1, 0, 0, 0),
                                         simd_float4(0, 1, 0, 0),
                                         simd_float4(0, 0, 1, 0),
                                         simd_float4(translationX, translationY, translationZ, 1)))
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

public func matrix_ortho_right_hand(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let rows = [
        simd_float4(2 / (right - left),                  0,                   0, (left + right) / (left - right)),
        simd_float4(0,                  2 / (top - bottom),                   0, (top + bottom) / (bottom - top)),
        simd_float4(0,                                   0, -1 / (farZ - nearZ),          nearZ / (nearZ - farZ)),
        simd_float4(0,                                   0,                   0,                               1 )
    ]
    return float4x4(rows: rows)
}

public func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}

public func makeScaleMatrix(_ xScale: Float, _ yScale: Float) -> simd_float4x4 {
    let rows = [
        simd_float4(xScale,      0, 0, 0),
        simd_float4(     0, yScale, 0, 0),
        simd_float4(     0,      0, 1, 0),
        simd_float4(     0,      0, 0, 1)
    ]
    return float4x4(rows: rows)
}

/**
 * https://developer.apple.com/documentation/metal/textures/creating_a_mipmapped_texture
 */
func mipmapCount(_ width: Int, _ height: Int) -> Int {
    let heightLevels = Int(ceil(log2(Float(height))))
    let widthLevels = Int(ceil(log2(Float(width))))
    let mipCount = (heightLevels > widthLevels) ? heightLevels : widthLevels;
    return mipCount
}


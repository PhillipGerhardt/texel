//
//  Fitting.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

enum ScaleMode: String, CaseIterable {
    /// maintain aspect, letterbox
    case fit
    /// maintain aspect, fill whole layer
    case fill
    /// ignore aspect, fill whole layer
    case stretch
    /// original size
    case original
}

enum VerticalAlignment: String, CaseIterable {
    case top
    case center
    case bottom
}

enum HorizontalAlignment: String, CaseIterable {
    case left
    case center
    case right
}

func fit(_ child: simd_int2, into parent: simd_float2, mode: ScaleMode) -> simd_float2 {
    let child = simd_float2(Float(child.x), Float(child.y))
    return fit(child, into: parent, mode: mode)
}

func fit(_ child: simd_float2, into parent: simd_float2, mode: ScaleMode) -> simd_float2 {

    let sx = parent.x / child.x
    let sy = parent.y / child.y
    switch mode {
    case .stretch:
        return simd_float2(child.x * sx, child.y * sy)
    case .fit:
        if sx < sy  {
            return child * sx
        } else {
            return child * sy
        }
    case .fill:
        if sx > sy  {
            return child * sx
        } else {
            return child * sy
        }
    case .original:
        return child
    }
}

func align(_ child: simd_float2, into parent: simd_float2, vertical: VerticalAlignment, horizontal: HorizontalAlignment) -> simd_float2 {
    let dt = parent - child
    var res = simd_float2.zero

    switch horizontal {
    case .left:
        res.x = -dt.x * 0.5
    case .center:
        break
    case .right:
        res.x = dt.x * 0.5
    }

    switch vertical {
    case .top:
        res.y = dt.y * 0.5
    case .center:
        break
    case .bottom:
        res.y = -dt.y * 0.5
    }

    return res
}

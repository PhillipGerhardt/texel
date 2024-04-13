//
//  Enums.swift
//  Texel
//
//  Created by Phillip Gerhardt on 07.04.24.
//

import Metal

enum TriangleFillMode: String, CaseIterable {
    case fill
    case lines

    var mode: MTLTriangleFillMode {
        switch self {
        case .fill:
            return MTLTriangleFillMode.fill
        case .lines:
            return MTLTriangleFillMode.lines
        }
    }
}

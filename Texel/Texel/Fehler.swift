//
//  Fehler.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Foundation

enum Fehler: Error {
    case CVMetalTextureCacheCreate
    case makeDefaultLibrary
    case makeDepthStencilState
}

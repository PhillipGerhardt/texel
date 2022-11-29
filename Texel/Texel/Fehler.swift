//
//  Fehler.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Foundation

/**
 * Fehler is the german word for Error
 */
enum Fehler: Error {
    case CVMetalTextureCacheCreate
    case makeDefaultLibrary
    case makeDepthStencilState
    case makeTexture
    case CGContext
}

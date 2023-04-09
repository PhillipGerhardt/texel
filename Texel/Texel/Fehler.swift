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
    case makeBuffer
    case CGContext
    case makeCommandQueue
    case CIFilter
    case layer
    case URLWithString(string: String)
    case avformat_open_input
    case avcodec_open2
    case swr_init
    case swr_alloc_set_opts
}

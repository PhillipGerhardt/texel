//
//  Texture.swift
//  Texel
//
//  Created by Phillip Gerhardt on 03.12.22.
//

import MetalKit

protocol TextureContent {
    var texture: MTLTexture? { get }
}

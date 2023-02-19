//
//  Raw.swift
//  Texel
//
//  Created by Phillip Gerhardt on 19.02.23.
//

import MetalKit

/**
 * Show raw image.
 */
class RawContent: Content, TextureContent {
    var size: simd_int2 = .zero
    var texture: MTLTexture?
    var buffer: MTLBuffer?

    convenience init(path: String, width: Int, height: Int, bytesPerPixel: Int) {
        self.init(url: URL(fileURLWithPath: path), width: width, height: height, bytesPerPixel: bytesPerPixel)
    }

    init(url: URL, width: Int, height: Int, bytesPerPixel: Int) {
        Task {
            do {
                size = simd_int2(Int32(width), Int32(height))
                let pixelSize = 4
                let length = width * height * pixelSize
                let bytesPerRow = width * pixelSize
                let numPixels = width * height
                let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
                textureDescriptor.usage = [.shaderRead]
                guard let buffer = engine.device.makeBuffer(length: length, options: [.storageModeManaged]) else { throw Fehler.makeBuffer }
                guard let texture = buffer.makeTexture(descriptor: textureDescriptor, offset: 0, bytesPerRow: bytesPerRow) else { throw Fehler.makeBuffer }
                memset(buffer.contents(), 0xff, length)
                let data = try Data(contentsOf: url)
                data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                    (0..<(numPixels)).forEach { index in
                        memcpy(buffer.contents().advanced(by: index * pixelSize), ptr.baseAddress?.advanced(by: index * bytesPerPixel), bytesPerPixel)
                    }
                }

                self.buffer = buffer
                self.texture = texture
            } catch {
                print("error", error)
            }
        }
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        if let texture = texture {
            renderEncoder.setFragmentTexture(texture, index: TextureIndex.one.rawValue)
            renderEncoder.setRenderPipelineState(engine.pipelineContent)
            return true
        }
        return false
    }

}

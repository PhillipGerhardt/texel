//
//  Image.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//


import MetalKit

/**
 * Show an image.
 */
class ImageContent: Content, TextureContent {
    var size: simd_int2 = .zero
    var texture: MTLTexture?
    var semaphore: DispatchSemaphore?

    convenience init(path: String, loadSync: Bool? = nil) {
        self.init(url: URL(fileURLWithPath: path), loadSync: loadSync)
    }

    init(url: URL, loadSync: Bool? = nil) {
        if loadSync == true {
            semaphore = DispatchSemaphore(value: 0)
        }
        Task {
            defer { semaphore?.signal() }
            let options: [MTKTextureLoader.Option: Any] = [
                .allocateMipmaps: true,
                .generateMipmaps: true,
                .textureStorageMode: MTLStorageMode.private.rawValue,
                .SRGB: false
            ]
            do {
                texture = try await engine.textureLoader.newTexture(URL: url, options: options)
                if let texture = texture {
                    size = simd_int2(Int32(texture.width), Int32(texture.height))
                    // extend texture with a size property?
                }
            } catch {
                print("error loading \(url):", error)
            }
        }
        semaphore?.wait()
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

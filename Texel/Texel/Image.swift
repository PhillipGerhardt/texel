//
//  Image.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//


import MetalKit

fileprivate extension OperationQueue {
    convenience init(maxConcurrentOperationCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
}

fileprivate let operationQueue = OperationQueue(maxConcurrentOperationCount: 8)

/**
 * Show an image.
 */
class ImageContent: Content, TextureContent {
    var size: simd_int2 = .zero
    var texture: MTLTexture?

    convenience init(path: String, loadSync: Bool? = nil) {
        self.init(url: URL(fileURLWithPath: path), loadSync: loadSync)
    }

    init(url: URL, loadSync: Bool? = nil) {

        func load(image: ImageContent) {
            let options: [MTKTextureLoader.Option: Any] = [
                .allocateMipmaps: true,
                .generateMipmaps: true,
                .textureStorageMode: MTLStorageMode.private.rawValue,
                .SRGB: false
            ]
            do {
                let texture = try engine.textureLoader.newTexture(URL: url, options: options)
                image.size = simd_int2(Int32(texture.width), Int32(texture.height))
                image.texture = texture
            } catch {
                print("error loading \(url):", error)
            }
        }

        if loadSync == true {
            load(image: self)
        } else {
            operationQueue.addOperation { [weak self] in
                if let self {
                    load(image: self)
                }
            }
        }
    }

    deinit {
//        print("ImageContent.deinit")
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

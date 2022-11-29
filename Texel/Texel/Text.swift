//
//  Text.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import MetalKit

/**
 * Draw some text into a metal texture.
 */
class TextContent: Content {
    var size: simd_int2 = .zero
    var texture: MTLTexture?
    var text: String { didSet { try? draw() } }
    var backgroundColor: simd_float4 = .zero { didSet { try? draw() } }
    var foregroundColor: simd_float4 = .one { didSet { try? draw() } }
    var fontSize: Float = 18 { didSet { try? draw() } }

    init(text: String, size: simd_int2) throws {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(size.x), height: Int(size.y), mipmapped: false)
        textureDescriptor.usage = [.shaderRead]
        textureDescriptor.storageMode = .shared
        guard let texture = engine.device.makeTexture(descriptor: textureDescriptor) else {
            throw Fehler.makeTexture
        }
        self.text = text
        self.size = size
        self.texture = texture
        try draw()
    }

    func draw() throws {
        /* NOP when texture have not yet been created. */
        guard texture != nil else { return }

        guard let ctx = CGContext(data: nil,
                                  width: Int(size.x),
                                  height: Int(size.y),
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space:  CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw Fehler.CGContext
        }

        ctx.setFillColor(CGColor(red: CGFloat(backgroundColor.x), green: CGFloat(backgroundColor.y), blue: CGFloat(backgroundColor.z), alpha: CGFloat(backgroundColor.w)))
        ctx.fill(size.rect)

        let path = CGMutablePath()
        path.addRect(size.rect)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: CGFloat(fontSize)),
            NSAttributedString.Key.foregroundColor: NSColor(red: CGFloat(foregroundColor.x), green: CGFloat(foregroundColor.y), blue: CGFloat(foregroundColor.z), alpha: CGFloat(foregroundColor.w)),
        ]
        let attrString = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, nil)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), attributes as CFDictionary, size.rect.size, nil)
        let diff = (size.rect.height - frameSize.height) / 2
        ctx.textMatrix = .identity
        ctx.translateBy(x: 0, y: -diff)
        CTFrameDraw(frame, ctx)
        ctx.translateBy(x: 0, y: diff)

        self.texture?.replace(region: MTLRegion(origin: .init(x: 0, y: 0, z: 0), size: .init(width: Int(size.x), height: Int(size.y), depth: 1)), mipmapLevel: 0, withBytes: ctx.data!, bytesPerRow: ctx.bytesPerRow)
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

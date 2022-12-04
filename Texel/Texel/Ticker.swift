//
//  Ticker.swift
//  Texel
//
//  Created by Phillip Gerhardt on 04.12.22.
//

import Metal
import Combine
import CoreGraphics
import AVFoundation
import AppKit

class TickerContent: Content {
    var size: simd_int2 = .one
    var speed: Int = 100
    var fontSize: Float = 64
    var backgroundColor: simd_float4 = simd_float4(0, 0, 0, 1)
    var foregroundColor: simd_float4 = .one

    var context: CGContext
    var line: CTLine
    var imageBounds: CGRect
    var typographicWidth: Float

    var textures = [MTLTexture]()
    var updates = [0, 0, 0]
    var offset: Float = 0
    var rounds: Int = 2

    fileprivate var token: AnyCancellable?
    fileprivate var startTime: CFTimeInterval = 0
    fileprivate var stopTime: CFTimeInterval = 0

    init(size: simd_int2, text: String, speed: Int?, fontSize: Float?, foregroundColor: simd_float4?, backgroundColor: simd_float4?) throws {
        self.size = size
        self.speed = speed ?? self.speed
        self.fontSize = fontSize ?? self.fontSize
        self.foregroundColor = foregroundColor ?? self.foregroundColor
        self.backgroundColor = backgroundColor ?? self.backgroundColor

        guard let context = CGContext(data: nil,
                                      width: Int(size.x),
                                      height: Int(size.y),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space:  CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw Fehler.CGContext
        }
        context.setBlendMode(.copy)
        context.setFillColor(CGColor(red: CGFloat(self.backgroundColor.x), green: CGFloat(self.backgroundColor.y), blue: CGFloat(self.backgroundColor.z), alpha: CGFloat(self.backgroundColor.w)))
        context.fill(size.rect)
        self.context = context
        let attributes = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: CGFloat(self.fontSize)),
            NSAttributedString.Key.foregroundColor: NSColor(red: CGFloat(self.foregroundColor.x), green: CGFloat(self.foregroundColor.y), blue: CGFloat(self.foregroundColor.z), alpha: CGFloat(self.foregroundColor.w)),
            NSAttributedString.Key.backgroundColor: NSColor(red: CGFloat(self.backgroundColor.x), green: CGFloat(self.backgroundColor.y), blue: CGFloat(self.backgroundColor.z), alpha: CGFloat(self.backgroundColor.w)),
        ]
        let string = NSAttributedString(string: text, attributes: attributes)
        line = CTLineCreateWithAttributedString(string)
        imageBounds = CTLineGetImageBounds(line, context)
        typographicWidth = Float(CTLineGetTypographicBounds(line, nil, nil, nil))

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(size.x), height: Int(size.y), mipmapped: false)
        textureDescriptor.usage = [.shaderRead]

        try (0...2).forEach { _ in
            guard let texture = engine.device.makeTexture(descriptor: textureDescriptor) else {
                throw Fehler.makeTexture
            }
            texture.replace(region: size.region, mipmapLevel: 0, withBytes: context.data!, bytesPerRow: context.bytesPerRow)
            textures.append(texture)
        }

    }

    deinit {
        token?.cancel()
    }

    func start() {
        startTime = CACurrentMediaTime() - stopTime
        token = engine.contentTick.sink { [weak self] in
            if let this = self {
                Task {
                    this.step()
                }
            }
        }
    }

    func stop() {
        token = nil
        stopTime = CACurrentMediaTime() - startTime
    }

    func step() {
        let elapsed = CACurrentMediaTime() - startTime
        let scrolled = Float(elapsed) * Float(speed)
        let offsetPosition = scrolled.truncatingRemainder(dividingBy: Float(size.x))
        let offset = offsetPosition / Float(size.x)
        let rounds = Int(scrolled / Float(size.x)) + 2 //

        while let max = updates.max(), max < rounds {
            let min = updates.min()!
            let i = updates.firstIndex(of: min)!
            updates[i] = max + 1

            context.setFillColor(CGColor(red: CGFloat(backgroundColor.x), green: CGFloat(backgroundColor.y), blue: CGFloat(backgroundColor.z), alpha: CGFloat(backgroundColor.w)))
            context.fill(size.rect)

            var x: Float = 0
            let distance = Float(max) * Float(size.x)
            if distance > 0 {
                let q = distance.truncatingRemainder(dividingBy: typographicWidth)
                x = -q
            }
            while x < Float(size.x) {
                context.textPosition = CGPoint(x: CGFloat(x), y: CGFloat(size.y / 2) - imageBounds.height / 2)
                CTLineDraw(line, context)
                x += typographicWidth
            }
            let textureIndex = (max + 1 + 2) % 3
            textures[textureIndex].replace(region: size.region, mipmapLevel: 0, withBytes: context.data!, bytesPerRow: context.bytesPerRow)
        }
        self.rounds = rounds
        self.offset = offset
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        let rounds = self.rounds
        let offset = self.offset

        let i = (rounds + 0) % 3
        let j = (rounds + 1) % 3

        var modelTicker = ModelTicker(offset: offset)
        renderEncoder.setRenderPipelineState(engine.pipelineTicker)
        renderEncoder.setFragmentTexture(textures[i], index:  TextureIndex.one.rawValue)
        renderEncoder.setFragmentTexture(textures[j], index:  TextureIndex.two.rawValue)
        renderEncoder.setFragmentBytes(&modelTicker, length: MemoryLayout<ModelTicker>.size, index: BufferIndex.modelTicker.rawValue)
        return true
    }
}

//
//  Filter.swift
//  Texel
//
//  Created by Phillip Gerhardt on 25.02.23.
//

import Metal
import Quartz
import Combine

class FilterContent: Content, TextureContent {

    var size: simd_int2 = .zero
    var texture: MTLTexture?
    let filter: CIFilter
    let renderDestination: CIRenderDestination

    @Published var time: Float = 0
    var timeToken: AnyCancellable?
    var token: AnyCancellable?

    var dirty = true

    var attributes: [[String]] { get {
        var res = [[String]]()
        for (key, val) in filter.attributes {
            if let val = val as? [String:Any] {
                var a = [key]
                [kCIAttributeClass, kCIAttributeDefault, kCIAttributeDescription].forEach {
                    let v = val[$0] ?? "nil"
                    a.append("\(v)")
                }
                res.append(a)
            }
        }
        return res
    }}

    init(name: String, size: simd_int2) throws {
        self.size = size
        guard let filter = CIFilter(name: name) else {
            throw Fehler.CIFilter
        }
        self.filter = filter
        self.filter.setDefaults()
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb, width: Int(size.x), height: Int(size.y), mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        textureDescriptor.storageMode = .shared
        guard let texture = engine.device.makeTexture(descriptor: textureDescriptor) else {
            throw Fehler.makeTexture
        }
        self.texture = texture
        renderDestination = CIRenderDestination(mtlTexture: texture, commandBuffer: nil)
    }

    func set(_ key: String, _ value: Any) {
        print(#function, key, value)
        dirty = true
        if let val = value as? TextureContent {
            if let texture = val.texture {
                let image = CIImage(mtlTexture: texture, options: nil)
                filter.setValue(image, forKeyPath: key)
            }
        }
        if let val = value as? Float {
            filter.setValue(NSNumber(value: val), forKeyPath: key)
        }
        if let val = value as? [Float] {
            if val.count == 2 {
                filter.setValue(CIVector(x: CGFloat(val[0]), y: CGFloat(val[1])), forKeyPath: key)
            }
            if val.count == 4 {
                filter.setValue(CIVector(x: CGFloat(val[0]), y: CGFloat(val[1]), z: CGFloat(val[2]), w: CGFloat(val[3])), forKeyPath: key)
            }
        }
    }

    func start() {
        if filter.attributes[kCIInputTimeKey] != nil {
            timeToken = $time.sink(receiveValue: { [weak self]  val in
                guard let self else { return }
                self.dirty = true
                self.filter.setValue(NSNumber(value: val), forKeyPath: kCIInputTimeKey)
            })
        }
        token = engine.contentTick.sink { [weak self] in
            guard let self else { return }
            if let output = self.filter.value(forKeyPath: kCIOutputImageKey) as? CIImage {
                let task = try? engine.coreImageContext.startTask(toRender: output, to: self.renderDestination)
                _ = try? task?.waitUntilCompleted()
                self.dirty = false
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

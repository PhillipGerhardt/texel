//
//  Layer.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Combine

/**
 * @Published properties can be animated.
 */

class Layer {

    var sublayers = [Layer]()
    var clip: Bool = false // clip content and childlayers to this layer size
    var draw: Bool = true
    @Published var position = simd_float2.zero
    @Published var size = simd_float2.one
    @Published var orientation = simd_quatf(angle: 0, axis: simd_float3(0,0,1))
    @Published var rotation: Float = 0 // convenience. easier than orientation
    @Published var pivot = simd_float2(0.5, 0.5) // maybe rename to anchorPoint
    @Published var color = simd_float4(0.0, 0.5, 0.5, 1.0) // teal
    @Published var contentColor = simd_float4.one
    @Published var contentVolume: Float = 1
    var content: Content? {
        didSet {
            guard content != nil else {
                contentVolumeToken = nil
                return
            }
            contentVolumeToken = $contentVolume.sink(receiveValue: { [weak self]  val in
                guard let self else { return }
                self.content?.volume = val
            })
        }
    }
    var contentVolumeToken: AnyCancellable?
    var contentScaling: ScaleMode = .fit
    var contentHorizontalAlignment: HorizontalAlignment = .center
    var contentVerticalAlignment: VerticalAlignment = .center

    var contentSize: simd_float2 {
        get {
            if let content = content {
                let size = fit(content.size, into: size, mode: contentScaling)
                return size
            }
            return .zero
        }
    }

    var contentTranslation: simd_float2 {
        get {
            return align(contentSize, into: size, vertical: contentVerticalAlignment, horizontal: contentHorizontalAlignment)
        }
    }

    var contentTransform: simd_float4x4 {
        get {
            var t = matrix_identity_float4x4
            let dt = size - contentSize
            t = t.translated(-dt * pivot)
            t = t.translated(dt * 0.5)
            t = t.translated(contentTranslation)
            t = t.translated(-contentSize * pivot)
            t = t.translated(-1 * pivot )
            t = simd_matrix4x4(orientation) * t
            t = simd_matrix4x4(simd_quatf(angle: rotation, axis: simd_float3(0,0,1))) * t
            t = t.translated( 1 * pivot )
            t = t.translated(position)
            return t
        }
    }

    var transform: simd_float4x4 {
        get {
            var t = matrix_identity_float4x4
            t = t.translated(-1 * pivot * size)
            t = simd_matrix4x4(orientation) * t
            t = simd_matrix4x4(simd_quatf(angle: rotation, axis: simd_float3(0,0,1))) * t
            t = t.translated( 1 * pivot * size)
            t = t.translated(position - (pivot * size))
            return t
        }
    }

    var childTransform: simd_float4x4 {
        get {
            var t = matrix_identity_float4x4
            t = t.translated(-1 * pivot )
            t = simd_matrix4x4(orientation) * t
            t = simd_matrix4x4(simd_quatf(angle: rotation, axis: simd_float3(0,0,1))) * t
            t = t.translated( 1 * pivot )
            t = t.translated(position)
            return t
        }
    }

    init() {
    }

    deinit {
        print("Layer.deinit")
    }

}

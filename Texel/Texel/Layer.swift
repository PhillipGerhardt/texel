//
//  Layer.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Combine

/**
 * The scene consists of layers and their sublayers.
 * @Published properties can be animated.
 */
class Layer {
    var children = [Layer]()

    /// Allows interaction with events
    var interactive = true

    /// Clip content and childlayers to this layer size
    var clip: Bool = false

    /// Draw the layer
    var draw: Bool = true

    /// Position of the layer
    @Published var position = simd_float2.zero {
        didSet { _position = Published<simd_float2>(wrappedValue: position) }
    }

    /// Size of the layer
    @Published var size = simd_float2.one {
        didSet { _size = Published<simd_float2>(wrappedValue: size) }
    }

    /// The orientation of the layer. Used to rotate the layer when the user clicks them with the mouse
    @Published var orientation = simd_quatf(angle: 0, axis: simd_float3(0,0,1)) {
        didSet { _orientation = Published<simd_quatf>(wrappedValue: orientation) }
    }

    /// Rotation about z axis. Exported to JS
    @Published var rotation: Float = 0 {
        didSet { _rotation = Published<Float>(wrappedValue: rotation) }
    }

    /// The pivot or anchorpoint. Rotation and position is calculated from that point.
    @Published var pivot = simd_float2(0.5, 0.5) {
        didSet { _pivot = Published<simd_float2>(wrappedValue: pivot) }
    }

    /// Color used to draw the layer. Default: teal
    @Published var color = simd_float4(0.0, 0.5, 0.5, 1.0) {
        didSet { _color = Published<simd_float4>(wrappedValue: color) }
    }

    /// Color that is multiplied with the color of the content's textures pixels. Can be used to fade the content in and out
    @Published var contentColor = simd_float4.one {
        didSet { _contentColor = Published<simd_float4>(wrappedValue: contentColor) }
    }

    /// Control the volume of the content. Fade content in and out
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

    /// Control how the content is laid out in the layer
    var contentScaling: ScaleMode = .fit

    /// Control the horizontal alignment of the content in the layer
    var contentHorizontalAlignment: HorizontalAlignment = .center

    /// Control the vertical alignment of the content in the layer
    var contentVerticalAlignment: VerticalAlignment = .center

    /// Size of content after applying the contentScaling
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

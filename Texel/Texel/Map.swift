//
//  Map.swift
//  Texel
//
//  Created by Phillip Gerhardt on 11.03.23.
//

import Metal
import Quartz
import Combine
import MapKit

class MapContent: Content {
    var size: simd_int2 = .zero

    var texture: MTLTexture?
    let renderer: CARenderer
    let mapView: MKMapView
    let layer: CALayer

    init(size: simd_int2 = simd_int2(2048, 2048)) throws {
        self.size = size

        mapView = MKMapView(frame: size.rect)
        mapView.wantsLayer = true

        guard let layer = mapView.layer else {
            throw Fehler.layer
        }
        self.layer = layer

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(size.x), height: Int(size.y), mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .renderTarget]
        textureDescriptor.storageMode = .shared
        guard let texture = engine.device.makeTexture(descriptor: textureDescriptor) else {
            throw Fehler.makeTexture
        }
        self.texture = texture

        renderer = CARenderer(mtlTexture: texture, options: nil)
        renderer.layer = layer
        renderer.bounds = layer.bounds
    }

    fileprivate var token: AnyCancellable?
    func start() {
        token = engine.contentTick.sink { [weak self] in
            if let this = self {
                Task {
                    this.step()
                }
            }
        }
    }

    let semaphore = DispatchSemaphore(value: 1)
    func step() {
        if semaphore.wait(timeout: .now()) == .timedOut { return }
        defer { semaphore.signal() }
        renderContent()
    }

    func renderContent() {
        renderer.beginFrame(atTime: CACurrentMediaTime(), timeStamp: nil)
        renderer.render()
        renderer.endFrame()
    }

    func configure(_ renderEncoder: MTLRenderCommandEncoder) -> Bool {
        if let texture = texture {
            renderEncoder.setFragmentTexture(texture, index: TextureIndex.one.rawValue)
            renderEncoder.setRenderPipelineState(engine.pipelineContentFlipped)
            return true
        }
        return false
    }

    func onEvent(_ event: NSEvent, at point: simd_float2) {
        if event.type == .leftMouseDragged {
            var coordinate = mapView.centerCoordinate
            let span = mapView.region.span

            coordinate.latitude += event.deltaY * span.latitudeDelta * 0.01
            coordinate.latitude = max(-90, coordinate.latitude)
            coordinate.latitude = min(90, coordinate.latitude)

            coordinate.longitude -= event.deltaX * span.longitudeDelta * 0.01
            coordinate.longitude = max(-180, coordinate.longitude)
            coordinate.longitude = min(180, coordinate.longitude)

            self.mapView.setCenter(coordinate, animated: false)
        }
        if event.type == .scrollWheel {
            var region = mapView.region

            region.span.latitudeDelta -= Double(event.deltaY) * 10
//            region.span.latitudeDelta = max(0.1, region.span.latitudeDelta)
            region.span.latitudeDelta = min(180, region.span.latitudeDelta)

            region.span.longitudeDelta -= Double(event.deltaY) * 10
//            region.span.longitudeDelta = max(0.1, region.span.longitudeDelta)
            region.span.longitudeDelta = min(180, region.span.longitudeDelta)

//            print(region)

            if region.span.latitudeDelta > 0, region.span.longitudeDelta > 0 {
                mapView.setRegion(mapView.regionThatFits(region), animated: true)
            }
        }
    }

}

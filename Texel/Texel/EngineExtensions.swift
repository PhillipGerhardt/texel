//
//  EngineExtensions.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import QuickLookThumbnailing
import ImageIO

extension Engine {

    func saveThumbnail(of src: String, to dst: String, size: simd_float2) {
        let srcURL = URL(fileURLWithPath: src)
        let dstURL = URL(fileURLWithPath: dst)
        let req = QLThumbnailGenerator.Request(fileAt: srcURL, size: .init(width: CGFloat(size.x), height: CGFloat(size.y)), scale: 1, representationTypes: .lowQualityThumbnail)
        let semaphore = DispatchSemaphore(value: 1)
        QLThumbnailGenerator.shared.generateBestRepresentation(for: req) { (rep, error) in
            defer { semaphore.signal() }
            guard let rep = rep, error == nil else { return }
            let destination = CGImageDestinationCreateWithURL(dstURL as CFURL, UTType.png.identifier as CFString, 1, nil)!
            CGImageDestinationAddImage(destination, rep.cgImage, nil)
            CGImageDestinationFinalize(destination)
        }
        semaphore.wait()
    }

}

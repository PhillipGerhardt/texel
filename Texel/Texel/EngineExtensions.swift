//
//  EngineExtensions.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import QuickLookThumbnailing
import ImageIO
import AVFoundation

extension Engine {

    /**
     * Create a thumbnail of a file
     */
    class func saveThumbnail(of src: String, to dst: String, size: simd_float2) {
        let srcURL = URL(fileURLWithPath: src)
        let dstURL = URL(fileURLWithPath: dst)
        let req = QLThumbnailGenerator.Request(fileAt: srcURL, size: .init(width: CGFloat(size.x), height: CGFloat(size.y)), scale: 1, representationTypes: .lowQualityThumbnail)
        let semaphore = DispatchSemaphore(value: 0)
        QLThumbnailGenerator.shared.generateBestRepresentation(for: req) { (rep, error) in
            defer { semaphore.signal() }
            guard let rep = rep, error == nil else { return }
            let destination = CGImageDestinationCreateWithURL(dstURL as CFURL, UTType.png.identifier as CFString, 1, nil)!
            CGImageDestinationAddImage(destination, rep.cgImage, nil)
            CGImageDestinationFinalize(destination)
        }
        semaphore.wait()
    }

    class func imageSize(at url: URL) -> simd_int2? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] else { return nil }
        guard let width = props[kCGImagePropertyPixelWidth] as? Int32 ,
              let height = props[kCGImagePropertyPixelHeight]  as? Int32 else { return nil }
        return simd_int2(width, height)
    }

    class func movieSize(at url: URL) -> simd_int2? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return simd_int2(Int32(size.width), Int32(size.height))
    }

    class func size(of url: URL) -> simd_int2? {
        if isImage(url: url) {
            return imageSize(at: url)
        }
        if isMovie(url: url) {
            return movieSize(at: url)
        }
        return nil
    }

    class func isMovie(url: URL) -> Bool {
        guard let type = UTType(filenameExtension: url.pathExtension) else { return false }
        let result = type.conforms(to: .audiovisualContent)
        return result
    }

    class func isImage(url: URL) -> Bool {
        guard let type = UTType(filenameExtension: url.pathExtension) else { return false }
        let result = type.conforms(to: .image) && !type.conforms(to: .pdf)
        return result
    }

}

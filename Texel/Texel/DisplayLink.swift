//
//  DisplayLink.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import CoreVideo

public final class DisplayLink {
    var displayLink: CVDisplayLink!
    var callback: (() -> Void)?

    public init() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)

        func displayLinkOutputCallback(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            if let displayLinkContext = displayLinkContext {
                Unmanaged<DisplayLink>.fromOpaque(displayLinkContext).takeUnretainedValue().onDisplayLinkOutput()
            }
            return kCVReturnSuccess
        }

        CVDisplayLinkSetOutputCallback(displayLink, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }

    deinit {
        print("DisplayLink.deinit")
    }

    public func start(callback: @escaping () -> Void) {
        self.callback = callback
        CVDisplayLinkStart(displayLink)
    }

    public func stop() {
        CVDisplayLinkStop(displayLink)
    }

    func onDisplayLinkOutput() {
        callback?()
    }

}

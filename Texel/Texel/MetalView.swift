//
//  MetalView.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import MetalKit

/**
 * Subclass is needed for keyUp and keyDown.
 * Nextresponder is set to the view controller.
 */
class MetalView: MTKView {

    override public var acceptsFirstResponder: Bool { true }

    public override func keyDown(with event: NSEvent) {
        nextResponder?.keyDown(with: event)
    }
    public override func keyUp(with event: NSEvent) {
        nextResponder?.keyUp(with: event)
    }

}

//
//  Window.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AppKit

/**
 * A borderless window cannot become key or main.
 * That's why we use a subclass.
 */
class Window: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

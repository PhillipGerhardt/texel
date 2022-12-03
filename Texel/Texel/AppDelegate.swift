//
//  AppDelegate.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var windows = [Window]()
    var controllers = [MetalViewController]()

    func makeWindow(in rect: NSRect) {
        let styleMask: NSWindow.StyleMask = [.closable, .resizable, .titled]
//        let styleMask: NSWindow.StyleMask = [.borderless]
        let window = Window(contentRect: rect, styleMask: styleMask, backing: .buffered, defer: false)
        window.title = "Texel"
        window.level = .statusBar
        window.isRestorable = false
        let viewController = MetalViewController()
        window.contentViewController = viewController
        window.makeKeyAndOrderFront(nil)
        window.setFrame(rect, display: true)
        windows.append(window)
        controllers.append(viewController)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let screen = NSScreen.screens.last else { return }
        makeWindow(in: screen.frame)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}

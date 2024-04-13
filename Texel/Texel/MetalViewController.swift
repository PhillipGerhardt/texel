//
//  MetalViewController.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AppKit

class MetalViewController: NSViewController {

    var renderer: Renderer!
    var mtkView: MetalView!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let rect = NSRect(origin: .zero, size: .init(width: 512, height: 512))
        mtkView = MetalView(frame: rect, device: engine.device)
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = true
        self.view = mtkView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.device = engine.device
        guard let renderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }
        self.renderer = renderer
        mtkView.delegate = renderer
        mtkView.nextResponder = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    }

    public override func viewDidAppear() {
        renderer.start()
//        renderer.mtkView(mtkView, drawableSizeWillChange: CGSize(width: 512, height: 512))
    }

    override func viewWillDisappear() {
        renderer.stop()
    }

    override func viewDidDisappear() {
        renderer.stop()
    }

}

extension MetalViewController {

    func onEvent(event: NSEvent) {
        var point = self.view.convert(event.locationInWindow, from: nil)
        let scale = self.view.window?.backingScaleFactor ?? 1
        point.x /= self.view.bounds.width
        point.y /= self.view.bounds.height
        let evt = Event(point: point, with: event, scale: scale)
        engine.scene.events.append(evt)
    }

    public override func mouseDown(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func mouseUp(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func mouseDragged(with event: NSEvent) {
        onEvent(event: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func rightMouseDragged(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func otherMouseDragged(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func keyDown(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func keyUp(with event: NSEvent) {
        onEvent(event: event)
    }

    public override func scrollWheel(with event: NSEvent) {
        onEvent(event: event)
    }

}

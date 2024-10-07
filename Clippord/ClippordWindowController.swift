//
//  ClippordWindowController.swift
//  Clippord
//
//  Created by Julio Palma on 10/6/24.
//

import SwiftUI

class ClippordWindowController: NSWindowController, NSWindowDelegate {
    var onClose: (() -> Void)?
    
    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 230, height: 600),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clippord"
        
        let contentView = NSHostingView(rootView: Clippord())
        window.contentView = contentView
        super.init(window: window)
        
        self.window?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWindow() {
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        if let currentScreen = NSScreen.main {
            let currentScreenFrame = currentScreen.visibleFrame
            self.window?.setFrameTopLeftPoint(NSPoint(x: currentScreenFrame.minX + 20, y: currentScreenFrame.maxY - 20))
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        closeWindow()
    }
    
    func closeWindow() {
        self.window?.delegate = nil
        self.close()
        onClose?()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose?()
    }
}

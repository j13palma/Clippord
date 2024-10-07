//
//  PreferencesWindowController.swift
//  Clippord
//
//  Created by Julio Palma on 10/7/24.
//


import SwiftUI

class PreferencesWindowController: NSWindowController {
    static let shared = PreferencesWindowController()

    private init() {
        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Preferences"
        window.setContentSize(NSSize(width: 300, height: 200))
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false // Keep the window around after closing
        window.center()
        
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) // Bring the app and window to the front
    }
}

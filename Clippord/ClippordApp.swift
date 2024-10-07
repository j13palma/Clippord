//
//  ClippordApp.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import SwiftUI

@main
struct ClippordApp: App {
    @State private var windowController: ClippordWindowController?
    
    var body: some Scene {
        MenuBarExtra("Clippord", systemImage: "doc.on.clipboard") {
            ClippordMenuBar()
            Button("Open Clippord Window") {
                showMainWindow()
            }
        }
    }
    private func createWindowController() -> ClippordWindowController {
        let controller = ClippordWindowController()
        controller.onClose = {
            self.windowController = nil
        }
        return controller
    }
    
    private func showMainWindow() {
        if windowController == nil {
            windowController = createWindowController()
        }
        
        windowController?.showWindow()
    }
}

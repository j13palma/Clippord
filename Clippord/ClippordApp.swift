//
//  ClippordApp.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import SwiftUI

@main
struct ClippordApp: App {
    var body: some Scene {
        WindowGroup {
            Clippord()
                .onAppear {
                    positionWindowNextToActiveScreen()
                }
            //                .onAppear {
            //                // Listen for when the app loses focus
            //                NotificationCenter.default.addObserver(
            //                    forName: NSApplication.willResignActiveNotification,
            //                    object: nil,
            //                    queue: .main
            //                ) { _ in
            //                    // Quit the app when it loses focus
            //                    NSApplication.shared.terminate(nil)
            //                }
            //            }
        }
    }
    
    private func positionWindowNextToActiveScreen() {
        if let window = NSApplication.shared.windows.first {
            // Get the active screen where the cursor is currently located
            if let screen = NSScreen.main {
                // Get the frame of the active screen
                let screenFrame = screen.visibleFrame
                
                // Set the desired window width and height
                let windowWidth: CGFloat = 300
                let windowHeight: CGFloat = 400
                
                // Calculate the new window position (e.g., top-left corner of the active screen)
                let windowX = screenFrame.minX + 20  // Offset 20 points from left edge
                let windowY = screenFrame.maxY - windowHeight - 20  // Offset 20 points from top edge
                
                // Set the window frame to the new position
                window.setFrame(NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight), display: true)
            }
        }
    }
}

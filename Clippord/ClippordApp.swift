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
}

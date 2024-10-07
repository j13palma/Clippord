//
//  ClippordApp.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let openClippord = Self("openClippord", default: .init(.v, modifiers: [.command, .option]))
}

@main
struct ClippordApp: App {
    private let windowManager = WindowManager() // Now mutable
    
    init() {
        KeyboardShortcuts.onKeyUp(for: .openClippord) { [self] in
            print(KeyboardShortcuts.Name.openClippord)
            windowManager.showMainWindow()
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
           VStack{
                ClippordMenuBar()
                
                Divider()
                Button("Open Clippord Window") {
                    windowManager.showMainWindow()
                }
                .globalKeyboardShortcut(.openClippord)
                
                Divider()
                Button("Preferences...") {
                    PreferencesWindowController.shared.showWindow()
                }
                .keyboardShortcut(",", modifiers: [.command])
                
                Button("Quit Clippord") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: [.command])
            }
            
        }label: {
            let image: NSImage = {
                    let ratio = $0.size.height / $0.size.width
                    $0.size.height = 18
                    $0.size.width = 18 / ratio
                    return $0
                }(NSImage(named: "ClippordMenuBar")!)

                Image(nsImage: image)
        }
    }
}

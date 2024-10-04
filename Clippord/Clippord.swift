//
//  ContentView.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import SwiftUI

struct Clippord: View {
    @State private var clipboardContent: String = ""
    @State private var clippordData = ClippordData(clips: [])
    @State private var previousClipboardContent: String = ""
    @State private var hoverStates: [String: Bool] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(clippordData.clips, id: \.self) { clip in
                let cleanClip = clip.trimmingCharacters(in: .whitespaces)
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(clip, forType: .string)
                }) {
                    Text(cleanClip)
                        .frame(width: 200, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(5)
                }
                .background(hoverStates[clip] == true ? Color.accentColor : Color.clear)
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(5)
                .frame(width: 200, alignment: .leading)
                .padding(.leading, 10)
                .onHover { hovering in
                    hoverStates[clip] = hovering  // Update hover state when the mouse enters/exits
                }
                .animation(.easeInOut(duration: 0.2), value: hoverStates[clip] ?? false)

            }
               
            Divider()
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            
            if !clippordData.clips.isEmpty {
                Text("Clear Clippord")
                    .padding(.leading, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Update clipboard content when the view appears
            startClipboardPolling()
            setWindowSize(width: 230, height: 600)
        }
    }

    private func startClipboardPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateClipboardContent()
        }
    }
    
    private func setWindowSize(width: CGFloat, height: CGFloat) {
        if let window = NSApplication.shared.windows.first {
            let newSize = NSSize(width: width, height: height)
            window.setContentSize(newSize)  // Set the window content size
        }
    }
    
    // Function to update the clipboard content
    private func updateClipboardContent() {
        let pasteboard = NSPasteboard.general
        if let content = pasteboard.string(forType: .string) {
                    // Check if the clipboard content has changed
            if content != previousClipboardContent {
                // Update the previous clipboard content
                previousClipboardContent = content
                           
                // Update the state with the new clipboard content
                clipboardContent = content
                           
                // Append new content to the clips array if it is not already there
                if !clippordData.clips.contains(content) {
                    clippordData.clips.append(content)
                }
            }
        }
    }
}


#Preview {
    Clippord()
}

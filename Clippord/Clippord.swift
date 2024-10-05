//
//  ContentView.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import SwiftUI

struct Clippord: View {
    @State private var clipboardContent: String = ""
    @State private var previousClipboardContent: String = ""
    @State private var showWindow = false
    @State private var floatingWindow: NSWindow?
    @State private var isHovering = false
    
    @ObservedObject var clipboardManager = ClipboardManager.shared
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(clipboardManager.getClips(), id: \.self) { clip in
                let cleanClip = clip.trimmingCharacters(in: .whitespaces)
                StyledButton(label: cleanClip)
                    .onHover { hovering in
                        if !hovering {
                            isHovering = false
                            removeFloatingWindow()
                        }else{
                            isHovering = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if isHovering {
                                    showFloatingText(clip)
                                }
                            }
                        }
                    }
            }
            Divider()
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            
            if !ClipboardManager.shared.isEmpty() {
                StyledButton(label: "Clear Clippord", action: {
                    clipboardManager.clearClips()
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Update clipboard content when the view appears
            startClipboardPolling()
            setWindowSize(width: 230, height: 600)
        }
    }
    
    private func showFloatingText(_ text: String) {
        removeFloatingWindow()
        
        let maxWidth: CGFloat = 200
        let fixedHeight: CGFloat = 300
        
        let textWidth = min(maxWidth, (text as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: 14)]).width + 40)  // Add padding
        
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: textWidth, height: fixedHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        
        let view = NSHostingView(rootView: VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .truncationMode(.tail)
                .frame(maxWidth: maxWidth, alignment: .leading)
                .padding(10)
                .alignmentGuide(.top) { d in d[.top] }
                .background()
                .opacity(0.9)
                .cornerRadius(10)
            Spacer()
        }
            .frame(maxHeight: fixedHeight, alignment: .top)
            .background(Color.clear)
        )
        window.contentView = view
        
        if let parentWindow = NSApplication.shared.windows.first, let screen = parentWindow.screen {
            let parentFrame = parentWindow.frame
            let availableSpaceOnRight = screen.visibleFrame.maxX - parentFrame.maxX
            var windowX = parentFrame.maxX + 10
            
            if availableSpaceOnRight < window.frame.width {
                windowX = parentFrame.minX - window.frame.width - 10
            }
            
            let windowY = parentFrame.maxY - window.frame.height
            window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
            
        } else if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowX = screenFrame.midX - window.frame.width / 2
            let windowY = screenFrame.midY
            window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        }
        
        window.orderFront(nil)
        floatingWindow = window
    }
    
    private func removeFloatingWindow() {
        floatingWindow?.orderOut(nil)
        floatingWindow = nil
    }
    
    private func deleteItem(_ item: String) {
        if let index = clipboardManager.getIndex(of: item) {
            clipboardManager.removeClip(at: index)
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
                if !clipboardManager.containsClip(content) {
                    clipboardManager.addClip(content)
                }
            }
        }
    }
}

struct StyledButton: View {
    var label: String
    var action: (() -> Void)?
    @State private var hoverStates: [String: Bool] = [:]
    
    var body: some View {
        Button(action: {action?()}) {
            Text(label)
                .frame(width: 200, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(5)
                .background(hoverStates[label] == true ? Color.accentColor : Color.clear)
                .cornerRadius(5)
        }
        .frame(width: 200, alignment: .leading)
        .padding(.leading, 10)
        .onHover { hovering in
            hoverStates[label] = hovering  // Update hover state when the mouse enters/exits
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: hoverStates[label] ?? false)
    }
}



#Preview {
    Clippord()
}

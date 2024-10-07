//
//  ContentView.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import SwiftUI

func copyToClipboard(_ content: String) {
    ClippordManager.shared.ignoreNextClipboardChange()
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(content, forType: .string)
}

class WindowDelegate: NSObject, NSWindowDelegate, ObservableObject {
    var onClose: (() -> Void)?
    
    func windowDidResignKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.delegate = nil
            window.close()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose?()
    }
}

struct ClipView: View {
    let clip: String
    let isPinned: Bool
    @State private var hoverStates: [String: Bool] = [:]
    @State private var showWindow = false
    @State private var floatingWindow: NSWindow?
    @State private var isHovering = false
    @State private var pinHovering = false
    
    var body: some View {
        let cleanClip = clip.trimmingCharacters(in: .whitespacesAndNewlines)
        
        HStack {
            Button(action: {copyToClipboard(clip)}) {
                Text(cleanClip)
                    .frame(width: 150, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(5)
                    .background(hoverStates[clip] == true ? Color.accentColor : Color.clear)
                    .cornerRadius(5)
            }
            .frame(width: 150, alignment: .leading)
            .padding(.leading, 10)
            .onHover { hovering in
                hoverStates[clip] = hovering
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
            .buttonStyle(PlainButtonStyle())
            .animation(.easeInOut(duration: 0.2), value: hoverStates[clip] ?? false)
            .focusable(false)
            
            Spacer()
            
            Button(action: {
                togglePin()
            }) {
                Image(systemName: pinHovering ? "star.fill" : "star")
                    .foregroundColor(isPinned && !pinHovering || !isPinned && pinHovering ? .yellow :  .gray)
            }
            .padding(5)
            .focusable(false)
            .onHover { hovering in
                pinHovering = hovering
            }
        }
    }
    
    private func togglePin() {
        if isPinned {
            ClippordManager.shared.unpinClip(clip)
        } else {
            ClippordManager.shared.pinClip(clip)
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
        
        if let parentWindow = NSApplication.shared.windows.first(where: { $0.title == "Clippord" }), let screen = parentWindow.screen {
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
            hoverStates[label] = hovering
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: hoverStates[label] ?? false)
        .focusable(false)
    }
}

struct Clippord: View {
    @ObservedObject var clipboardManager = ClippordManager.shared
    @StateObject private var windowDelegate = WindowDelegate()
    
    @State private var isPinnedClipsExpanded: Bool = UserDefaults.standard.bool(forKey: "pinnedClipsStateKey") {
        didSet {
            UserDefaults.standard.set(self.isPinnedClipsExpanded, forKey: "pinnedClipsStateKey")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !clipboardManager.pinnedClips.isEmpty {
                HStack {
                    Button(action: {
                        isPinnedClipsExpanded.toggle()
                    }) {
                        HStack {
                            Text("Pinned Clips")
                                .font(.headline)
                            Spacer()
                            Image(systemName: isPinnedClipsExpanded ? "chevron.down" : "chevron.right")
                        }
                    }
                    .frame(width: 220)
                    .buttonStyle(PlainButtonStyle())
                    .padding(10)
                    .focusable(false)
                }
                if isPinnedClipsExpanded {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(clipboardManager.pinnedClips.reversed(), id: \.self) { clip in
                                ClipView(clip: clip, isPinned: true)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                    Divider()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
            }
            Text("Clips").font(.headline).padding(.leading, 10)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(clipboardManager.clips.reversed(), id: \.self) { clip in
                        ClipView(clip: clip, isPinned: clipboardManager.isPinned(clip))
                    }
                }
            }
            
            if !clipboardManager.clips.isEmpty {
                Spacer()
                Divider()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                StyledButton(label: "Clear Clippord", action: {
                    clipboardManager.clearClips()
                })
                .padding(.bottom, 5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            setupWindowFocusObserver()
            setWindowSize(width: 230, height: 600)
        }
    }
    
    private func setWindowSize(width: CGFloat, height: CGFloat) {
        if let window = NSApplication.shared.windows.first {
            let newSize = NSSize(width: width, height: height)
            window.setContentSize(newSize)
        }
    }
    
    private func setupWindowFocusObserver() {
        if let window = NSApplication.shared.windows.first {
            window.delegate = windowDelegate
        }
    }
}



#Preview {
    Clippord()
}

//
//  Data.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import Combine
import Foundation
import SwiftUI

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published private(set) var clips: [String] = []
    @Published private(set) var pinnedClips: [String] = []
    
    private let pinnedFileURL: URL
    private(set) var previousClipboardContent: String = ""
    private var shouldIgnoreClipboardChange = false
    
    private init() {
        let fileManager = FileManager.default
        let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupportDir.appendingPathComponent("Clippord")
        
        // Create the Clippord directory if it doesn't exist
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        pinnedFileURL = appDirectory.appendingPathComponent("pinnedClips.json")
        
        loadPinnedClips()
    }
    
    func startClipboardPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateClipboardContent()
        }
    }
    
    private func updateClipboardContent() {
        let pasteboard = NSPasteboard.general
        if let content = pasteboard.string(forType: .string) {
            if shouldIgnoreClipboardChange {
                shouldIgnoreClipboardChange = false
                return
            }
            
            if content != previousClipboardContent {
                previousClipboardContent = content
                
                if !containsClip(content) {
                    addClip(content)
                }
            }
        }
    }
    
    func ignoreNextClipboardChange() {
        shouldIgnoreClipboardChange = true
    }
    
    func addClip(_ clip: String) {
        if !pinnedClips.contains(clip) {
            clips.append(clip)
        }
    }
    
    func containsClip(_ clip: String) -> Bool {
        return clips.contains(clip)
    }
    
    func removeClip(at index: Int) {
        guard clips.indices.contains(index) else { return }
        clips.remove(at: index)
    }
    
    func clearClips() {
        clips.removeAll(keepingCapacity: true)
    }
    
    func getClips() -> [String] {
        return clips
    }
    
    func pinClip(_ clip: String) {
        if let index = clips.firstIndex(of: clip) {
            clips.remove(at: index)
            pinnedClips.append(clip)
            savePinnedClips()
        }
    }
    
    func unpinClip(_ clip: String) {
        if let index = pinnedClips.firstIndex(of: clip) {
            pinnedClips.remove(at: index)
            clips.append(clip)
            savePinnedClips()
        }
    }
    
    func isPinned(_ clip: String) -> Bool {
        return pinnedClips.contains(clip)
    }
    
    private func savePinnedClips() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(pinnedClips) {
            try? data.write(to: pinnedFileURL)
        }
    }
    
    private func loadPinnedClips() {
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: pinnedFileURL),
           let savedClips = try? decoder.decode([String].self, from: data) {
            pinnedClips = savedClips
        }
    }
}

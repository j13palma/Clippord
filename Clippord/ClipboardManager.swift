//
//  Data.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//
import Combine

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()  // Singleton instance
    
    // Array to store clipData in memory
    @Published private(set) var clips: [String] = []
    
    private init() {}  // Private initializer to ensure it's a singleton
    
    // Function to add a new clip
    func addClip(_ clip: String) {
        clips.append(clip)
    }
    
    func containsClip(_ clip: String) -> Bool {
        return clips.contains(clip)
    }
    
    func getIndex(of clip: String) -> Int? {
        return clips.firstIndex(of: clip)
    }
    
    // Function to remove a clip
    func removeClip(at index: Int) {
        guard clips.indices.contains(index) else { return }
        clips.remove(at: index)
    }
    
    // Function to clear all clips
    func clearClips() {
        clips.removeAll(keepingCapacity: true)
    }
    
    func isEmpty() -> Bool {
        return clips.isEmpty
    }
    
    // Function to get all clips
    func getClips() -> [String] {
        return clips
    }
}

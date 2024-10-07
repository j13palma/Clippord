//
//  ClippordMenuBar.swift
//  Clippord
//
//  Created by Julio Palma on 10/5/24.
//

import SwiftUI

struct ClippordMenuBar: View {
    @ObservedObject var clipboardManager = ClippordManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !clipboardManager.pinnedClips.isEmpty {
                Text("Pinned Clips")
                    .font(.headline)
                    .padding(10)
                    .frame(width: 220)
                ForEach(clipboardManager.pinnedClips.reversed().prefix(10), id: \.self) { clip in
                    let cleanClip = String(clip.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40).trimmingCharacters(in: .whitespacesAndNewlines) +
                                           (clip.trimmingCharacters(in: .whitespacesAndNewlines).count > 40 ? "...": ""))
                    StyledButton(label: cleanClip, action: {copyToClipboard(clip)})
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                Divider()
            }
            
            Text("Clips").font(.headline).padding(.leading, 10)
            ForEach(clipboardManager.clips.reversed().prefix(10), id: \.self) { clip in
                let cleanClip = String(clip.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40).trimmingCharacters(in: .whitespacesAndNewlines) +
                                       (clip.trimmingCharacters(in: .whitespacesAndNewlines).count > 40 ? "...": ""))
                StyledButton(label: cleanClip, action: {copyToClipboard(clip)})
            }
            Divider()
            
            if !clipboardManager.clips.isEmpty {
                StyledButton(label: "Clear Clippord", action: {
                    clipboardManager.clearClips()
                }).padding(0)
            }
        }
    }
    
}

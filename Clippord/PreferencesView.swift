//
//  PreferencesView.swift
//  Clippord
//
//  Created by Julio Palma on 10/7/24.
//


import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct PreferencesView: View {
    var body: some View {
        VStack {
            Text("Clippord")
                .font(.title)
            Text("v1.0.0")
                .padding(.bottom, 20)
            
            Image("Clippord")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Adjust to a desired size
                .padding(.bottom, 20)
                .cornerRadius(10)
            
            Spacer()
            
            HStack {
                Image(systemName: "keyboard")
                
                KeyboardShortcuts.Recorder(for: .openClippord) {
                    Text("Shortcut to Open Clippord")
                }
            }
            .padding(.bottom, 20)
            
            LaunchAtLogin.Toggle("🐾 Launch at login 🐾")
                .padding(.bottom, 20)
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 350)
    }
}

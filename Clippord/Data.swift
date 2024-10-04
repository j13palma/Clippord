//
//  Data.swift
//  Clippord
//
//  Created by Julio Palma on 10/2/24.
//

import Foundation

struct ClippordData: Codable {
    var clips: [String]
}

let data: ClippordData = .init(clips: [""])

//
//  Superlink.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI

struct Superlink: Identifiable {
    let name: String
    let asset: String
    let urlScheme: String
    
    var id: String {
        "\(name)_\(asset)"
    }
    
    init(name: String, asset: String, urlScheme: String) {
        self.name = name
        self.asset = asset
        self.urlScheme = urlScheme
    }
    
    init(name: String, urlScheme: String) {
        self.name = name
        self.asset = name.lowercased()
            .replacingOccurrences(of: " ", with: "-") // "Google Meet" → "google-meet"
            .appending("-icon")
        self.urlScheme = urlScheme.appending("://")
    }
    
    init(name: String) {
        self.name = name
        self.asset = name.lowercased()
            .replacingOccurrences(of: " ", with: "-") // "Google Meet" → "google-meet"
            .appending("-icon")
        
        self.urlScheme = name.lowercased()
            .replacingOccurrences(of: " ", with: "") // "Google Meet" → "googlemeet"
            .appending("://")
    }
}

// Array
extension Superlink {
    static let apps: [Superlink] = [
        Superlink(name: "Instagram"),
        Superlink(name: "TikTok"),
        Superlink(name: "YouTube"),
        Superlink(name: "Reddit"),
        Superlink(name: "Threads", urlScheme: "barcelona"),
        Superlink(name: "Safari", urlScheme: "x-web-search"),
        Superlink(name: "Chess", urlScheme: "fb2427617054"),
        Superlink(name: "Bloomberg"),
        Superlink(name: "Clash of Clans"),
        Superlink(name: "Clash Royale"),
        Superlink(name: "Hay Day"),
        Superlink(name: "Brawl Stars"),
        Superlink(name: "Facebook", urlScheme: "fb"),
        Superlink(name: "Google Chrome"),
        Superlink(name: "Gmail", urlScheme: "googlegmail"),
        Superlink(name: "Pinterest"),
        Superlink(name: "Snapchat"),
        Superlink(name: "Substack"),
        Superlink(name: "Discord"),
    ]
}

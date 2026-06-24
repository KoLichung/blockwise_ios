//
//  Superlink+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI

extension Superlink {
    enum SuperlinkError: LocalizedError {
        case invalidURL(scheme: String)
        case cannotOpen(scheme: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL(let scheme):
                return "Invalid URL scheme: \(scheme)"
            case .cannotOpen(let scheme):
                return "Cannot open \(scheme). The app may not be installed."
            }
        }
    }
    
    func canOpen() throws {
        guard URL(string: urlScheme) != nil else {
            throw SuperlinkError.invalidURL(scheme: urlScheme)
        }
    }
    
    // NOTE: “UIApplication.shared.canOpenURL(url)“ DOES NOT WORK RELIABLY. DONT USE IT.
    
    @MainActor
    func open(error: @escaping () -> Void) throws {
        guard let url = URL(string: urlScheme) else {
            throw SuperlinkError.invalidURL(scheme: urlScheme)
        }
        
        UIApplication.shared.open(url) { success in
            if !success {
                Logger.error("Could not open \(urlScheme).")
                error()
            }
        }
    }
    
    static func find(by id: String?) -> Superlink? {
        guard let id = id else { return nil }
        return Superlink.apps.first { $0.id == id }
    }
}

extension View {
    func appIconStyle(size: CGFloat) -> some View {
        self
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: size * 0.225, style: .continuous))
    }
}

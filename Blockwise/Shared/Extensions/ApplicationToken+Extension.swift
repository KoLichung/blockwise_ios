//
//  ApplicationToken+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 11/12/24.
//

import SwiftUI
import ManagedSettings

extension ApplicationToken {
    /// Encodes the `ApplicationToken` into a Base64-encoded string.
    var string: String? {
        do {
            let data = try JSONEncoder().encode(self)
            return data.base64EncodedString()
        } catch {
            print("Error encoding ApplicationToken: \(error)")
            return nil
        }
    }
    
    /// Decodes a Base64-encoded string into an `ApplicationToken`.
    ///
    /// - Parameter rawValue: A Base64-encoded string representation of an `ApplicationToken`.
    /// - Returns: An `ApplicationToken` if the decoding is successful; otherwise, `nil`.
    static func fromRawValue(_ rawValue: String) -> ApplicationToken? {
        guard let data = Data(base64Encoded: rawValue) else {
            print("Invalid Base64 string.")
            return nil
        }
        
        do {
            let token = try JSONDecoder().decode(ApplicationToken.self, from: data)
            return token
        } catch {
            print("Error decoding ApplicationToken: \(error)")
            return nil
        }
    }
}


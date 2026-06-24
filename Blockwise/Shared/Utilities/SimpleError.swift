//
//  SimpleError.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI

enum SimpleError: LocalizedError {
    case message(String)
    
    var errorDescription: String? {
        switch self {
        case .message(let text):
            return text
        }
    }
}

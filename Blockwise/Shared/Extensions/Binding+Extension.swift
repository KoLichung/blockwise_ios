//
//  Binding+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI

extension Binding where Value == Bool {
    /// Initializes a `Binding<Bool>` that reflects the presence of a non-nil value in an optional binding.
    ///
    /// - Parameters:
    ///   - value: A binding to an optional value. The resulting `Binding<Bool>` is `true` if `value` is non-nil,
    ///            and setting this binding to `false` sets `value` to `nil`.
    init<T>(value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}

extension Binding {
    /// Returns a Binding<Bool> that is true when the wrapped value equals the given value.
    func equals<T: Equatable>(_ value: T) -> Binding<Bool> where Value == T? {
        Binding<Bool>(
            get: { self.wrappedValue == value },
            set: { isSelected in
                self.wrappedValue = isSelected ? value : nil
            }
        )
    }
}

extension Binding {
    /// Creates a binding for a `Bool` that checks whether an element is in an array.
    /// - Parameters:
    ///   - collection: The collection to check.
    ///   - element: The element to find in the collection.
    /// - Returns: A binding to a `Bool` that reflects the presence of the element.
    static func isPresent<T: Equatable>(
        in collection: Binding<[T]>,
        element: T
    ) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                collection.wrappedValue.contains(element)
            },
            set: { newValue in
                if newValue {
                    if !collection.wrappedValue.contains(element) {
                        collection.wrappedValue.append(element)
                    }
                } else {
                    collection.wrappedValue.removeAll { $0 == element }
                }
            }
        )
    }
}

//
//  Dictionary+Extension.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


extension Dictionary {

    @inlinable
    public mutating func append(contentsOf newElements: [Key: Value]) {
        self.merge(newElements) { (current, _) in current }
    }

    @inlinable
    public func appending(contentsOf newElements: [Key: Value]) -> [Key: Value] {
        self.merging(newElements) { (current, _) in current }
    }
}

extension Dictionary {

    /// Same values, corresponding to `map`ped keys.
      ///
      /// - Parameter transform: Accepts each key of the dictionary as its parameter
      ///   and returns a key for the new dictionary.
      /// - Postcondition: The collection of transformed keys must not contain duplicates.
    public func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed) rethrows -> [Transformed: Value] {
        .init(uniqueKeysWithValues: try map { (try transform($0.key), $0.value) })
    }

    /// Same values, corresponding to `map`ped keys.
      ///
      /// - Parameters:
      ///   - transform: Accepts each key of the dictionary as its parameter
      ///     and returns a key for the new dictionary.
      ///   - combine: A closure that is called with the values for any duplicate
      ///     keys that are encountered. The closure returns the desired value for
      ///     the final dictionary.
    public func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed,
        uniquingKeysWith combine: (Value, Value) throws -> Value
    ) rethrows -> [Transformed: Value] {
        try .init(map { (try transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }
    
    /// `compactMap`ped keys, with their values.
    ///
    /// - Parameter transform: Accepts each key of the dictionary as its parameter
    ///   and returns a potential key for the new dictionary.
    /// - Postcondition: The collection of transformed keys must not contain duplicates.
    public func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?) rethrows -> [Transformed: Value] {
        .init(uniqueKeysWithValues: try compactMap { (try transform($0.key), $0.value) as? (Transformed, Value) })
    }
    
}

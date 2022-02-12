//
//  Dictionary+Extension.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
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

    public func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed) rethrows -> [Transformed: Value] {
        .init(uniqueKeysWithValues: try map { (try transform($0.key), $0.value) })
    }
    
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed,
                              uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
        try .init(map { (try transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }
    
    
    public func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?) rethrows -> [Transformed: Value] {
        .init(uniqueKeysWithValues: try compactMap { (try transform($0.key), $0.value) as? (Transformed, Value) })
    }
}

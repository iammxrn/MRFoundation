//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

/// Atomic based on ReadWriteLock.
///
/// - Important: This property wrapper guarantees that the wrapped value will be thread-safe, as well as the absence of any side effects.
///
@propertyWrapper
public final class ReadWriteAtomic<Value>: Atomic {
    
    
    // MARK: - Public Properties
    
    public var wrappedValue: Value {
        get {
            value
        } _modify {
            yield &value
        }
    }
    
    public var projectedValue: ReadWriteAtomic<Value> { self }
    
    
    // MARK: - Internal Properties
    
    let _lock = ReadWriteLock()
    
    var _unsafeWrappedValue: Value
    
    
    // MARK: - Init
    
    public init(wrappedValue: Value) {
        self._unsafeWrappedValue = wrappedValue
    }
}

//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation

/// Atomic based on UnfairLock.
///
/// This type of lock can be a good choice when per-lock overhead is important (because for some reason you have a huge number of them)
/// and you don't need fancy features. It's implemented as a single 32-bit integer which you can place wherever you need it, so overhead is small.
@propertyWrapper
public final class UnfairAtomic<Value>: Atomic {
    
    
    // MARK: - Public Properties
    
    public var wrappedValue: Value {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    public var projectedValue: UnfairAtomic<Value> { self }
    
    
    // MARK: - Internal Properties
    
    let _lock = UnfairLock()
    
    var _unsafeWrappedValue: Value
    
    
    // MARK: - Init
    
    public init(wrappedValue: Value) {
        self._unsafeWrappedValue = wrappedValue
    }
}

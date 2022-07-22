//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


protocol Atomic: AnyObject {
    
    associatedtype Value
    
    associatedtype Lock: Locking
    
    var _lock: Lock { get }
    
    var _unsafeWrappedValue: Value { get set }
    
    @discardableResult
    func load<Result>(_ action: (Value) throws -> Result) rethrows -> Result
    
    @discardableResult
    func store<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result
}

extension Atomic {
    
    var value: Value {
        get {
            load { $0 }
        } set {
            swap(newValue)
        }
    }
    
    @discardableResult
    func load<Result>(_ action: (Value) throws -> Result) rethrows -> Result {
        try _lock.readLocked { try action(_unsafeWrappedValue) }
    }
    
    @discardableResult
    func store<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result {
        try _lock.writeLocked { try action(&_unsafeWrappedValue) }
    }
    
    @discardableResult
    private func swap(_ newValue: Value) -> Value {
        store { (value: inout Value) in
            let oldValue = value
            value = newValue
            return oldValue
        }
    }
}

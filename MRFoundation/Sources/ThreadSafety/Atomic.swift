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
    
}

extension Atomic {
    
    var value: Value {
        get {
            self._lock.rd_lock(); defer { self._lock.rd_unlock() }
            return _unsafeWrappedValue
        } _modify {
            self._lock.wr_lock(); defer { self._lock.wr_unlock() }
            yield &self._unsafeWrappedValue
        }
    }

}

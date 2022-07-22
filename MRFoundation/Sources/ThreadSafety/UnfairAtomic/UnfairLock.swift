//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


final class UnfairLock {
    
    
    // MARK: - Private Properties
    
    private let unfairLock: UnsafeMutablePointer<os_unfair_lock>
    
    
    // MARK: - Init
    
    init() {
        self.unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        self.unfairLock.initialize(to: .init())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    
    // MARK: - Public Methods
    
    func `try`() -> Bool {
        os_unfair_lock_trylock(unfairLock)
    }
    
    func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}


// MARK: - Locking

extension UnfairLock: Locking {
    
    @discardableResult
    func readLocked<Result>(_ action: () throws -> Result) rethrows -> Result {
        lock()
        defer { unlock() }
        return try action()
    }
    
    @discardableResult
    func writeLocked<Result>(_ action: () throws -> Result) rethrows -> Result {
        lock()
        defer { unlock() }
        return try action()
    }
}

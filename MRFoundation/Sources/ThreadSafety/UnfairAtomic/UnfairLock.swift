//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

public final class UnfairLock {
    
    
    // MARK: - Private Properties
    
    private let unfairLock: UnsafeMutablePointer<os_unfair_lock>
    
    
    // MARK: - Init
    
    public required init() {
        self.unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        self.unfairLock.initialize(to: .init())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    
    // MARK: - Public Methods
    
    public final func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    public final func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}


// MARK: - Locking

extension UnfairLock: Locking {
    
    func rd_lock() {
        lock()
    }
    
    func rd_unlock() {
        unlock()
    }
    
    func wr_lock() {
        lock()
    }
    
    func wr_unlock() {
        unlock()
    }
}

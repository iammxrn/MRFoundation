//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


final class ReadWriteLock {
    
    
    // MARK: - Private Properties
    
    private var readWriteLock: pthread_rwlock_t
    
    
    // MARK: - Init
    
    init() {
        readWriteLock = pthread_rwlock_t()
        pthread_rwlock_init(&readWriteLock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&readWriteLock)
    }
    
    
    // MARK: - Public Methods
    
    func readLock() {
        pthread_rwlock_rdlock(&readWriteLock)
    }
    
    func writeLock() {
        pthread_rwlock_wrlock(&readWriteLock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(&readWriteLock)
    }
    
    func tryRead() -> Bool {
        pthread_rwlock_tryrdlock(&readWriteLock) == 0
    }
    
    func tryWrite() -> Bool {
        pthread_rwlock_trywrlock(&readWriteLock) == 0
    }
}


// MARK: - Locking

extension ReadWriteLock: Locking {
    
    @discardableResult
    func readLocked<Result>(_ action: () throws -> Result) rethrows -> Result {
        readLock()
        defer { unlock() }
        return try action()
    }
    
    @discardableResult
    func writeLocked<Result>(_ action: () throws -> Result) rethrows -> Result {
        writeLock()
        defer { unlock() }
        return try action()
    }
}

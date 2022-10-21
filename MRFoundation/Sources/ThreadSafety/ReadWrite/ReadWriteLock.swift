//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

public final class ReadWriteLock {
    
    
    // MARK: - Private Properties
    
    private let readWriteLock: UnsafeMutablePointer<pthread_rwlock_t>
    
    
    // MARK: - Init
    
    public required init() {
        self.readWriteLock = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
        let err = pthread_rwlock_init(readWriteLock, nil)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")   
    }
    
    deinit {
        pthread_rwlock_destroy(readWriteLock)
        readWriteLock.deallocate()
    }
    
    
    // MARK: - Public Methods
    
    public func readLock() {
        let err = pthread_rwlock_rdlock(readWriteLock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }
    
    public func writeLock() {
        let err = pthread_rwlock_wrlock(readWriteLock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }
    
    public func unlock() {
        let err = pthread_rwlock_unlock(readWriteLock)
        precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
    }
    
}


// MARK: - Locking

extension ReadWriteLock: Locking {
    
    func rd_lock() {
        readLock()
    }
    
    func rd_unlock() {
        unlock()
    }
    
    func wr_lock() {
        writeLock()
    }
    
    func wr_unlock() {
        unlock()
    }
    
}

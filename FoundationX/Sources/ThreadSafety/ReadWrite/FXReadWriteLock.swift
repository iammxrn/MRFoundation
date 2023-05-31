import Foundation

public final class FXReadWriteLock {
    // MARK: Lifecycle

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

    // MARK: Public

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

    // MARK: Private

    // MARK: - Private Properties

    private let readWriteLock: UnsafeMutablePointer<pthread_rwlock_t>
}

// MARK: - Locking

extension FXReadWriteLock: Locking {
    func rd_lock() {
        self.readLock()
    }

    func rd_unlock() {
        self.unlock()
    }

    func wr_lock() {
        self.writeLock()
    }

    func wr_unlock() {
        self.unlock()
    }
}

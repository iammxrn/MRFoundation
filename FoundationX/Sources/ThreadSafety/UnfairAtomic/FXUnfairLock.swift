import Foundation

public final class FXUnfairLock {
    // MARK: Lifecycle

    // MARK: - Init

    public required init() {
        self.unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        self.unfairLock.initialize(to: .init())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    // MARK: Public

    // MARK: - Public Methods

    public final func lock() {
        os_unfair_lock_lock(self.unfairLock)
    }

    public final func unlock() {
        os_unfair_lock_unlock(self.unfairLock)
    }

    // MARK: Private

    // MARK: - Private Properties

    private let unfairLock: UnsafeMutablePointer<os_unfair_lock>
}

// MARK: - Locking

extension FXUnfairLock: Locking {
    func rd_lock() {
        self.lock()
    }

    func rd_unlock() {
        self.unlock()
    }

    func wr_lock() {
        self.lock()
    }

    func wr_unlock() {
        self.unlock()
    }
}

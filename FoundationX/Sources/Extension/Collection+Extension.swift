import Foundation

// MARK: - Subscript

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Parallel Map

public extension Collection {
    /// Parallels mapping using RecursiveLock.
    /// - Returns: An array containing the results of mapping the given closure over the sequence’s elements.
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)

        let lock = NSRecursiveLock()

        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }

        return res.map { $0! }
    }
}

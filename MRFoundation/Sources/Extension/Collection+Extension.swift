//
//  Collection+Extension.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


// MARK: - Subscript

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


// MARK: - Parallel Map

extension Collection {
    
    /// Parallels mapping using RecursiveLock.
    /// - Returns: An array containing the results of mapping the given closure over the sequence’s elements.
    public func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
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

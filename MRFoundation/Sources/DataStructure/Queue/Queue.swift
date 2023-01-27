//
//  Queue.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 1/27/23.
//  Copyright © 2023 Roman Mogutnov. All rights reserved.
//

/// An ordered, first-in-first-out (FIFO) collection
///
/// The Queue is implemented using a circular buffer, which allows for efficient enqueue and dequeue operations with a constant time complexity.
/// To optimize performance, it utilizes an UnsafeMutablePointer instead of a standard Swift Array.
///  The buffer automatically resizes to ensure optimal use of memory, by increasing the capacity when the number of elements
///  in the queue reaches the current capacity, and reducing it when it drops below a quarter of the current capacity.
public class Queue<T> {

    // MARK: - Private Properties

    private var buffer: UnsafeMutablePointer<T>

    private var head: Int = 0

    private var tail: Int = 0

    private var count: Int = 0

    // MARK: - Public Properties

    /// Maximum capacity of buffer
    public private(set) var capacity: Int

    /// The front element of the queue
    public var front: T? {
        return buffer[head]
    }

    /// A boolean indicating whether the queue is empty
    public var isEmpty: Bool {
        return count == 0
    }

    // MARK: - Public Init

    /// Initializes a new queue with a given capacity
    ///
    /// - Parameter capacity: The capacity of the queue. Default value is 10.
    public init(capacity: Int = 10) {
        self.capacity = capacity
        buffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
    }

    deinit {
        buffer.deallocate()
    }

    // MARK: - Public Methods

    /// Enqueues an element to the back of the queue
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameter element: The element to be added to the queue
    public func enqueue(_ element: T) {
        if count == capacity {
            resize(capacity: capacity * 2)
        }
        buffer[tail] = element
        tail = (tail + 1) % capacity
        count += 1
    }

    /// Dequeues the front element from the queue
    ///
    /// - Complexity: O(1)
    ///
    /// - Returns: The front element of the queue, or nil if the queue is empty
    @discardableResult
    public func dequeue() -> T? {
        if count == 0 {
            return nil
        }
        let element = buffer[head]
        head = (head + 1) % capacity
        count -= 1
        if count < capacity / 4 {
            resize(capacity: capacity / 2)
        }
        return element
    }

    // MARK: - Private Methods

    /// Resizes the queue to a given capacity
    ///
    /// - Complexity: O(n)
    ///
    /// - Parameter capacity: The new capacity of the queue
    private func resize(capacity: Int) {
        let newBuffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
        for i in 0..<count {
            newBuffer[i] = buffer[(head + i) % self.capacity]
        }
        buffer.deallocate()
        buffer = newBuffer
        head = 0
        tail = count
        self.capacity = capacity
    }

}

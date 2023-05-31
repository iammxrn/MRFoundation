/// An ordered, first-in-first-out (FIFO) collection
///
/// The FXQueue is implemented using a circular buffer, which allows for efficient enqueue and dequeue operations with a constant time complexity.
/// To optimize performance, it utilizes an UnsafeMutablePointer instead of a standard Swift Array.
///  The buffer automatically resizes to ensure optimal use of memory, by increasing the capacity when the number of elements
///  in the queue reaches the current capacity, and reducing it when it drops below a quarter of the current capacity.
public class FXQueue<T> {
    // MARK: Lifecycle

    // MARK: - Public Init

    /// Initializes a new queue with a given capacity
    ///
    /// - Parameter capacity: The capacity of the queue. Default value is 10.
    public init(capacity: Int = 10) {
        self.capacity = capacity
        self.buffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
    }

    deinit {
        buffer.deallocate()
    }

    // MARK: Public

    // MARK: - Public Properties

    /// Maximum capacity of buffer
    public private(set) var capacity: Int

    /// The front element of the queue
    public var front: T? {
        self.buffer[self.head]
    }

    /// A boolean indicating whether the queue is empty
    public var isEmpty: Bool {
        self.count == 0
    }

    // MARK: - Public Methods

    /// Enqueues an element to the back of the queue
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameter element: The element to be added to the queue
    public func enqueue(_ element: T) {
        if self.count == self.capacity {
            self.resize(capacity: self.capacity * 2)
        }
        self.buffer[self.tail] = element
        self.tail = (self.tail + 1) % self.capacity
        self.count += 1
    }

    /// Dequeues the front element from the queue
    ///
    /// - Complexity: O(1)
    ///
    /// - Returns: The front element of the queue, or nil if the queue is empty
    @discardableResult
    public func dequeue() -> T? {
        if self.count == 0 {
            return nil
        }
        let element = self.buffer[self.head]
        self.head = (self.head + 1) % self.capacity
        self.count -= 1
        if self.count < self.capacity / 4 {
            self.resize(capacity: self.capacity / 2)
        }
        return element
    }

    // MARK: Private

    // MARK: - Private Properties

    private var buffer: UnsafeMutablePointer<T>

    private var head: Int = 0

    private var tail: Int = 0

    private var count: Int = 0

    // MARK: - Private Methods

    /// Resizes the queue to a given capacity
    ///
    /// - Complexity: O(n)
    ///
    /// - Parameter capacity: The new capacity of the queue
    private func resize(capacity: Int) {
        let newBuffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
        for i in 0 ..< self.count {
            newBuffer[i] = self.buffer[(self.head + i) % self.capacity]
        }
        self.buffer.deallocate()
        self.buffer = newBuffer
        self.head = 0
        self.tail = self.count
        self.capacity = capacity
    }
}

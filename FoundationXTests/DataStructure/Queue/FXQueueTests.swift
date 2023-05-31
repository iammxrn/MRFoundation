import FoundationX
import XCTest

final class FXQueueTests: XCTestCase {
    func testEnqueue() {
        let queue = FXQueue<Int>()
        queue.enqueue(1)
        XCTAssertEqual(queue.front, 1)
    }

    func testDequeue() {
        let queue = FXQueue<Int>()
        queue.enqueue(1)
        let dequeued = queue.dequeue()
        XCTAssertEqual(dequeued, 1)
    }

    func testDequeueEmptyQueue() {
        let queue = FXQueue<Int>()
        let dequeued = queue.dequeue()
        XCTAssertNil(dequeued)
    }

    func testIsEmpty() {
        let queue = FXQueue<Int>()
        XCTAssertTrue(queue.isEmpty)
        queue.enqueue(1)
        XCTAssertFalse(queue.isEmpty)
    }

    func testAutoResize() {
        let queue = FXQueue<Int>(capacity: 10)
        for i in 0 ..< 11 {
            queue.enqueue(i)
        }
        XCTAssertEqual(queue.capacity, 20)
        for _ in 0 ..< 9 {
            queue.dequeue()
        }
        XCTAssertEqual(queue.capacity, 10)
    }

    func testEnqueueDequeueWraparound() {
        let queue = FXQueue<Int>()
        for i in 0 ..< 11 {
            queue.enqueue(i)
        }
        for i in 0 ..< 11 {
            XCTAssertEqual(queue.dequeue(), i)
        }
    }

    func testEnqueueDequeueWraparoundResize() {
        let queue = FXQueue<Int>()
        for i in 0 ..< 11 {
            queue.enqueue(i)
        }
        for i in 0 ..< 6 {
            XCTAssertEqual(queue.dequeue(), i)
        }
        for i in 11 ..< 16 {
            queue.enqueue(i)
        }
        for i in 6 ..< 11 {
            XCTAssertEqual(queue.dequeue(), i)
        }
        for i in 11 ..< 16 {
            XCTAssertEqual(queue.dequeue(), i)
        }
    }
}

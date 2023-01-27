//
//  QueueTests.swift
//  MRFoundationTests
//
//  Created by Roman Mogutnov on 1/27/23.
//  Copyright © 2023 Roman Mogutnov. All rights reserved.
//

import XCTest
import MRFoundation

final class QueueTests: XCTestCase {
    
    func testEnqueue() {
        let queue = Queue<Int>()
        queue.enqueue(1)
        XCTAssertEqual(queue.front, 1)
    }
    
    func testDequeue() {
        let queue = Queue<Int>()
        queue.enqueue(1)
        let dequeued = queue.dequeue()
        XCTAssertEqual(dequeued, 1)
    }
    
    func testDequeueEmptyQueue() {
        let queue = Queue<Int>()
        let dequeued = queue.dequeue()
        XCTAssertNil(dequeued)
    }
    
    func testIsEmpty() {
        let queue = Queue<Int>()
        XCTAssertTrue(queue.isEmpty)
        queue.enqueue(1)
        XCTAssertFalse(queue.isEmpty)
    }
    
    func testAutoResize() {
        let queue = Queue<Int>(capacity: 10)
        for i in 0..<11 {
            queue.enqueue(i)
        }
        XCTAssertEqual(queue.capacity, 20)
        for _ in 0..<9 {
            queue.dequeue()
        }
        XCTAssertEqual(queue.capacity, 10)
    }
    
    func testEnqueueDequeueWraparound() {
        let queue = Queue<Int>()
        for i in 0..<11 {
            queue.enqueue(i)
        }
        for i in 0..<11 {
            XCTAssertEqual(queue.dequeue(), i)
        }
    }
    
    func testEnqueueDequeueWraparoundResize() {
        let queue = Queue<Int>()
        for i in 0..<11 {
            queue.enqueue(i)
        }
        for i in 0..<6 {
            XCTAssertEqual(queue.dequeue(), i)
        }
        for i in 11..<16 {
            queue.enqueue(i)
        }
        for i in 6..<11 {
            XCTAssertEqual(queue.dequeue(), i)
        }
        for i in 11..<16 {
            XCTAssertEqual(queue.dequeue(), i)
        }
    }

}

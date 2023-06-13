//
//  KeychainProviderTests.swift
//  MRFoundationTests
//
//  Created by Roman Mogutnov on 5/26/23.
//  Copyright © 2023 Roman Mogutnov. All rights reserved.
//

import XCTest
import MRFoundation

class KeychainProviderTests: XCTestCase {

    struct SomeCodableStruct: Codable, Equatable {
        let value: Int

        init(_ value: Int) {
            self.value = value
        }
    }

    struct TestKey: MRKeychainProviderKey {

        init(_ id: UUID = UUID()) {
            self.init(rawValue: id.uuidString.lowercased())!
        }

        init?(rawValue: String) {
            self.rawValue = rawValue
        }

        var rawValue: String
    }

    var keychainProvider: MRKeychainProvider<TestKey>!

    override func setUp() {
        super.setUp()

        keychainProvider = MRKeychainProvider<TestKey>(service: "mrkeychain-provider-tests")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSetValue() {
        let key = TestKey()
        let value = "test value"

        let expectation = XCTestExpectation(description: "SetValue")
        keychainProvider.setValue(value, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testSetValueCodable() {
        let key = TestKey()
        let value = SomeCodableStruct(25)

        let expectation = XCTestExpectation(description: "SetValueCodable")
        keychainProvider.setValue(value, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testSetValuesCodable() {
        let key = TestKey()
        let values = [SomeCodableStruct(25), SomeCodableStruct(30)]

        let expectation = XCTestExpectation(description: "SetValuesCodable")
        keychainProvider.setValues(values, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testGetValue() {
        let key = TestKey()
        let expectedValue = "test value"

        let expectation = XCTestExpectation(description: "GetValue")
        keychainProvider.setValue(expectedValue, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
        var retrievedValue: String?
        XCTAssertNoThrow(retrievedValue = try keychainProvider.getValue(for: key))
        XCTAssertEqual(retrievedValue, expectedValue)
    }

    func testGetValueCodable() {
        let key = TestKey()
        let expectedValue = SomeCodableStruct(25)
        let expectation = XCTestExpectation(description: "GetValueCodable")
        keychainProvider.setValue(expectedValue, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
        var retrievedValue: SomeCodableStruct?
        XCTAssertNoThrow(retrievedValue = try keychainProvider.getValue(for: key))
        XCTAssertEqual(retrievedValue, expectedValue)
    }

    func testGetValuesCodable() {
        let key = TestKey()
        let expectedValues = [SomeCodableStruct(25), SomeCodableStruct(30)]

        let expectation = XCTestExpectation(description: "GetValuesCodable")
        keychainProvider.setValues(expectedValues, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)

        var retrievedValues: [SomeCodableStruct] = []
        XCTAssertNoThrow(retrievedValues = try keychainProvider.getValues(for: key))
        XCTAssertEqual(retrievedValues, expectedValues)
    }

    func testRemoveValue() {
        let key = TestKey()
        let value = "test value"

        let expectation = XCTestExpectation(description: "RemoveValue")

        keychainProvider.setValue(value, for: key) { error in
            XCTAssertNil(error)
            self.keychainProvider.removeValue(for: key) { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testRemoveAllValues() {
        let key = TestKey()
        let value = "test value"

        let expectation = XCTestExpectation(description: "RemoveAllValues")

        keychainProvider.setValue(value, for: key) { error in
            XCTAssertNil(error)
            self.keychainProvider.removeAllValues() { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testNonExistentKey() {
        let key = TestKey()

        var retrievedValue: String?
        XCTAssertNoThrow(retrievedValue = try keychainProvider.getValue(for: key))
        XCTAssertNil(retrievedValue)
    }

    func testOverwritingValue() {
        let key = TestKey()
        let initialValue = "initial value"
        let newValue = "new value"

        let expectation1 = XCTestExpectation(description: "InitialSetValue")
        keychainProvider.setValue(initialValue, for: key) { error in
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 60.0)

        let expectation2 = XCTestExpectation(description: "NewSetValue")
        keychainProvider.setValue(newValue, for: key) { error in
            XCTAssertNil(error)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 60.0)

        var retrievedValue: String?
        XCTAssertNoThrow(retrievedValue = try keychainProvider.getValue(for: key))
        XCTAssertEqual(retrievedValue, newValue)
    }

    func testSuccessfulRemoval() {
        let key = TestKey()
        let value = "testValue"

        let setExpectation = XCTestExpectation(description: "SetStringValue")
        keychainProvider.setValue(value, for: key) { error in
            XCTAssertNil(error)
            setExpectation.fulfill()
        }
        wait(for: [setExpectation], timeout: 60.0)

        let removeExpectation = XCTestExpectation(description: "RemoveValue")
        keychainProvider.removeValue(for: key) { error in
            XCTAssertNil(error)
            removeExpectation.fulfill()
        }
        wait(for: [removeExpectation], timeout: 60.0)

        var retrievedValue: String?
        XCTAssertNoThrow(retrievedValue = try keychainProvider.getValue(for: key))
        XCTAssertNil(retrievedValue)
    }

    func testRemovalNonExistentValue() {
        let key = TestKey()

        let removeExpectation = XCTestExpectation(description: "RemoveNonExistentValue")
        keychainProvider.removeValue(for: key) { error in
            XCTAssertNil(error)
            removeExpectation.fulfill()
        }
        wait(for: [removeExpectation], timeout: 60.0)
    }

    func testParallelWriting() {
        let key = TestKey()
        let values = Array(0..<1000).map { SomeCodableStruct($0) }
        let expectation = XCTestExpectation(description: "ParallelWriting")
        expectation.expectedFulfillmentCount = values.count

        for value in values {
            DispatchQueue.global().async {
                self.keychainProvider.setValue(value, for: key) { error in
                    XCTAssertNil(error)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testParallelWritingDifferentKeys() {
        let values = Array(0..<1000).map { (i) -> (key: TestKey, value: SomeCodableStruct) in
            (TestKey(UUID()), SomeCodableStruct(i))
        }
        let expectation = XCTestExpectation(description: "ParallelWritingDifferentKeys")
        expectation.expectedFulfillmentCount = values.count

        for value in values {
            DispatchQueue.global().async {
                self.keychainProvider.setValue(value.value, for: value.key) { error in
                    XCTAssertNil(error)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testParallelReading() {
        let key = TestKey()
        let expectedValue = SomeCodableStruct(25)
        keychainProvider.setValue(expectedValue, for: key) { error in
            XCTAssertNil(error)
        }

        let totalCount = 1000
        let expectation = XCTestExpectation(description: "ParallelReading")
        expectation.expectedFulfillmentCount = totalCount

        for _ in 0..<totalCount {
            DispatchQueue.global().async {
                do {
                    let retrievedValue: SomeCodableStruct? = try self.keychainProvider.getValue(for: key)
                    XCTAssertEqual(retrievedValue, expectedValue)
                    expectation.fulfill()
                } catch {
                    XCTFail("Error: \(error)")
                }
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testParallelReadingAndWriting() {
        let key = TestKey()
        let writeValues = Array(0..<1000).map { SomeCodableStruct($0) }
        let expectation = XCTestExpectation(description: "ConcurrentReadingAndWriting")

        let tasksCount = 2

        expectation.expectedFulfillmentCount = writeValues.count * tasksCount

        for value in writeValues {
            // Launch writing tasks
            DispatchQueue.global().async {
                self.keychainProvider.setValue(value, for: key) { error in
                    XCTAssertNil(error)
                    expectation.fulfill()
                }
            }

            // Launch reading tasks
            DispatchQueue.global().async {
                do {
                    _ = try self.keychainProvider.getValue(for: key) as SomeCodableStruct?
                    expectation.fulfill()
                } catch {
                    XCTFail("Error: \(error)")
                }
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testReadingWhileRemoving() {
        let key = TestKey()
        let expectedValue = SomeCodableStruct(25)

        let setExpectation = XCTestExpectation(description: "SetValue")
        keychainProvider.setValue(expectedValue, for: key) { error in
            XCTAssertNil(error)
            setExpectation.fulfill()
        }
        wait(for: [setExpectation], timeout: 60.0)

        let expectation = XCTestExpectation(description: "ReadingWhileRemoving")
        expectation.expectedFulfillmentCount = 2

        // Launch removing task
        DispatchQueue.global().async {
            self.keychainProvider.removeValue(for: key) { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }

        // Launch reading task
        DispatchQueue.global().async {
            do {
                let retrievedValue: SomeCodableStruct? = try self.keychainProvider.getValue(for: key)
                if let retrievedValue = retrievedValue {
                    XCTAssertEqual(retrievedValue, expectedValue)
                }
                expectation.fulfill()
            } catch {
                XCTFail("Error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testMultipleParallelOperations() {
        let key = TestKey()
        let writeValues = Array(0..<1000).map { SomeCodableStruct($0) }
        let expectation = XCTestExpectation(description: "MultipleParallelOperations")

        let tasksCount = 3
        expectation.expectedFulfillmentCount = writeValues.count * tasksCount

        for value in writeValues {
            // Launch writing tasks
            DispatchQueue.global().async {
                self.keychainProvider.setValue(value, for: key) { error in
                    XCTAssertNil(error)
                    expectation.fulfill()
                }
            }

            // Launch reading tasks
            DispatchQueue.global().async {
                do {
                    _ = try self.keychainProvider.getValue(for: key) as SomeCodableStruct?
                    expectation.fulfill()
                } catch {
                    XCTFail("Error: \(error)")
                }
            }

            // Launch removing tasks
            DispatchQueue.global().async {
                self.keychainProvider.removeValue(for: key) { error in
                    XCTAssertNil(error)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 60.0)
    }
}

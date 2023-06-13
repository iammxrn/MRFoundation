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

        wait(for: [expectation], timeout: 10.0)
    }

    func testSetValueCodable() {
        let key = TestKey()
        let value = SomeCodableStruct(25)

        let expectation = XCTestExpectation(description: "SetValueCodable")
        keychainProvider.setValue(value, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testSetValuesCodable() {
        let key = TestKey()
        let values = [SomeCodableStruct(25), SomeCodableStruct(30)]

        let expectation = XCTestExpectation(description: "SetValuesCodable")
        keychainProvider.setValues(values, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testGetValue() {
        let key = TestKey()
        let expectedValue = "test value"

        let expectation = XCTestExpectation(description: "GetValue")
        keychainProvider.setValue(expectedValue, for: key) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
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
        wait(for: [expectation], timeout: 10.0)
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
        wait(for: [expectation], timeout: 10.0)

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

        wait(for: [expectation], timeout: 10.0)
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

        wait(for: [expectation], timeout: 10.0)
    }

    func testParallelWriting() {
        let key = TestKey()
        let values = Array(0..<1000).map { SomeCodableStruct($0) }
        let dispatchGroup = DispatchGroup()
        let expectation = XCTestExpectation(description: "ParallelWriting")

        for value in values {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.keychainProvider.setValue(value, for: key) { error in
                    XCTAssertNil(error)
                    dispatchGroup.leave()
                }
            }
        }
        let result = dispatchGroup.wait(timeout: .now() + 10)
        switch result {
        case .success:
            expectation.fulfill()
        case .timedOut:
            XCTFail("Timeout occurred for parallel writing.")
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testParallelReading() {
        let key = TestKey()
        let expectedValue = SomeCodableStruct(25)
        keychainProvider.setValue(expectedValue, for: key) { error in
            XCTAssertNil(error)
        }
        let dispatchGroup = DispatchGroup()
        let expectation = XCTestExpectation(description: "ParallelReading")

        for _ in 0..<1000 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let retrievedValue: SomeCodableStruct? = try self.keychainProvider.getValue(for: key)
                    XCTAssertEqual(retrievedValue, expectedValue)
                } catch {
                    XCTFail("Error: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        let result = dispatchGroup.wait(timeout: .now() + 10)
        switch result {
        case .success:
            expectation.fulfill()
        case .timedOut:
            XCTFail("Timeout occurred for parallel reading.")
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testParallelReadingAndWriting() {
        let key = TestKey()
        let writeValues = Array(0..<1000).map { SomeCodableStruct($0) }
        let dispatchGroup = DispatchGroup()
        let expectation = XCTestExpectation(description: "ConcurrentReadingAndWriting")

        for value in writeValues {
            // Launch writing tasks
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.keychainProvider.setValue(value, for: key) { error in
                    XCTAssertNil(error)
                    dispatchGroup.leave()
                }
            }

            // Launch reading tasks
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    _ = try self.keychainProvider.getValue(for: key) as SomeCodableStruct?
                } catch {
                    XCTFail("Error: \(error)")
                }
                dispatchGroup.leave()
            }
        }

        let result = dispatchGroup.wait(timeout: .now() + 10)
        switch result {
        case .success:
            expectation.fulfill()
        case .timedOut:
            XCTFail("Timeout occurred for concurrent reading and writing.")
        }

        wait(for: [expectation], timeout: 10.0)
    }

}

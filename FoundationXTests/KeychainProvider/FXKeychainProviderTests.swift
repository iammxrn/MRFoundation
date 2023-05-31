import FoundationX
import XCTest

class FXKeychainProviderTests: XCTestCase {
    struct SomeCodableStruct: Codable, Equatable {
        // MARK: Lifecycle

        init(_ value: Int) {
            self.value = value
        }

        // MARK: Internal

        let value: Int
    }

    enum TestKey: String, FXKeychainProviderKey {
        case someValue
    }

    var keychainProvider: FXKeychainProvider<TestKey>!

    override func setUp() {
        super.setUp()

        self.keychainProvider = FXKeychainProvider<TestKey>(service: "fxkeychain-provider-tests")
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - SET

    func testSetValue() async {
        let key = TestKey.someValue
        let value = "test value"

        do {
            try await self.keychainProvider.setValue(value, for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSetValueCodable() async {
        let key = TestKey.someValue
        let value = SomeCodableStruct(25)

        do {
            try await self.keychainProvider.setValue(value, for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSetValuesCodable() async {
        let key = TestKey.someValue
        let values = [SomeCodableStruct(25), SomeCodableStruct(30)]

        do {
            try await self.keychainProvider.setValue(values, for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testParallelSet() async {
        let key = TestKey.someValue
        let values = Array(0 ..< 100).map { SomeCodableStruct($0) }

        let expectation = XCTestExpectation(description: "Keychain provider set all values")
        expectation.expectedFulfillmentCount = values.count

        await withTaskGroup(of: Void.self) { group in
            for value in values {
                group.addTask {
                    Task.detached {
                        do {
                            try await self.keychainProvider.setValue(value, for: key)
                            expectation.fulfill()
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testParallelReading() {
        let key = TestKey.someValue
        let expectedValue = SomeCodableStruct(25)

        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                try await self.keychainProvider.setValue(expectedValue, for: key)
                semaphore.signal()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        semaphore.wait()

        let totalReadings = 100

        let dispatchGroup = DispatchGroup()
        let expectation = XCTestExpectation(description: "Keychain provider get all values")
        expectation.expectedFulfillmentCount = totalReadings

        for _ in 0 ..< totalReadings {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let retrievedValue: SomeCodableStruct? = try self.keychainProvider.getValue(for: key)
                    XCTAssertEqual(retrievedValue, expectedValue)
                    print(Thread.current)
                } catch {
                    XCTFail("Error: \(error)")
                }
                expectation.fulfill()
                dispatchGroup.leave()
            }
        }
        let result = dispatchGroup.wait(timeout: .now() + 10)
        switch result {
        case .success:
            break
        case .timedOut:
            XCTFail("Timeout occurred for parallel reading.")
        }

        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - GET

    func testGetValue() async {
        let key = TestKey.someValue
        let expectedValue = "test value"

        do {
            try await self.keychainProvider.setValue(expectedValue, for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }

        var retrievedValue: String?
        XCTAssertNoThrow(retrievedValue = try self.keychainProvider.getValue(for: key))
        XCTAssertEqual(retrievedValue, expectedValue)
    }

    func testGetValueCodable() async {
        let key = TestKey.someValue
        let expectedValue = SomeCodableStruct(25)

        do {
            try await self.keychainProvider.setValue(expectedValue, for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }

        var retrievedValue: SomeCodableStruct?
        XCTAssertNoThrow(retrievedValue = try self.keychainProvider.getValue(for: key))
        XCTAssertEqual(retrievedValue, expectedValue)
    }

    func testGetValuesCodable() async {
        let key = TestKey.someValue
        let expectedValues = [SomeCodableStruct(25), SomeCodableStruct(30)]

        do {
            try await self.keychainProvider.setValue(expectedValues, for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }

        var retrievedValues: [SomeCodableStruct]? = []
        XCTAssertNoThrow(retrievedValues = try self.keychainProvider.getValue(for: key))
        XCTAssertEqual(retrievedValues, expectedValues)
    }

    // MARK: - REMOVE

    func testRemoveValue() async {
        let key = TestKey.someValue
        let value = "test value"

        do {
            try await self.keychainProvider.setValue(value, for: key)
            try await self.keychainProvider.removeValue(for: key)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRemoveAllValues() async {
        let key = TestKey.someValue
        let value = "test value"

        do {
            try await self.keychainProvider.setValue(value, for: key)
            try await self.keychainProvider.removeAllValues()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

import Foundation
import Security

public protocol FXKeychainProviderKey: RawRepresentable where RawValue == String {}

open class FXKeychainProvider<Key: FXKeychainProviderKey> {
    // MARK: Lifecycle

    // MARK: - Init

    public init(keychainQueryable: FXKeychainQueryable) {
        self.keychainQueryable = keychainQueryable
    }

    // MARK: Public

    // MARK: - Public Methods

    public func setValue(_ value: String, for key: Key, completion: ((Error?) -> Void)? = nil) {
        guard let encodedValue = value.data(using: .utf8) else {
            completion?(FXKeychainProviderError(
                code: .string2DataConversion,
                localizedDescription: "Invalid value: \(value)",
                systemMessage: "Cannot convert value: \(value) to binary data"
            ))
            return
        }
        self.setValue(encodedValue, for: key, completion: completion)
    }

    public func setValue(_ value: some Codable, for key: Key, completion: ((Error?) -> Void)? = nil) {
        guard let encodedValue = try? JSONEncoder().encode(value) else {
            completion?(FXKeychainProviderError(
                code: .codable2DataConversion,
                localizedDescription: "Invalid value: \(value)",
                systemMessage: "Cannot convert value: \(value) to binary data"
            ))
            return
        }
        self.setValue(encodedValue, for: key, completion: completion)
    }

    public func setValues(_ values: [some Codable], for key: Key, completion: ((Error?) -> Void)? = nil) {
        guard let encodedValue = try? JSONEncoder().encode(values) else {
            completion?(FXKeychainProviderError(
                code: .codable2DataConversion,
                localizedDescription: "Invalid values: \(values)",
                systemMessage: "Cannot convert value: \(values) to binary data"
            ))
            return
        }
        self.setValue(encodedValue, for: key, completion: completion)
    }

    public func setValue(_ value: Data, for key: Key, completion: ((Error?) -> Void)? = nil) {
        self.accessQueue.async(flags: .barrier) {
            var query = self.keychainQueryable.query
            query[String(kSecAttrAccount)] = key.rawValue

            var status = SecItemCopyMatching(query as CFDictionary, nil)
            switch status {
            case errSecSuccess:
                var attributesToUpdate: [String: Any] = [:]
                attributesToUpdate[String(kSecValueData)] = value

                status = SecItemUpdate(
                    query as CFDictionary,
                    attributesToUpdate as CFDictionary
                )
                if status != errSecSuccess {
                    completion?(self.error(from: status))
                }

            case errSecItemNotFound:
                query[String(kSecValueData)] = value

                status = SecItemAdd(query as CFDictionary, nil)
                if status != errSecSuccess {
                    completion?(self.error(from: status))
                }

            default:
                completion?(self.error(from: status))
            }

            completion?(nil)
        }
    }

    public func getValue(for key: Key) throws -> String? {
        guard let encodedValue: Data = try getValue(for: key) else {
            return nil
        }

        guard let value = String(data: encodedValue, encoding: .utf8) else {
            throw FXKeychainProviderError(
                code: .data2StringConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to string"
            )
        }

        return value
    }

    public func getValue<T: Codable>(for key: Key) throws -> T? {
        let encodedValue: Data? = try getValue(for: key)
        do {
            return try encodedValue.map {
                try JSONDecoder().decode(T.self, from: $0)
            }
        } catch {
            throw FXKeychainProviderError(
                code: .data2CodableConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to codable"
            )
        }
    }

    public func getValues<T: Codable>(for key: Key) throws -> [T] {
        let encodedValue: Data? = try getValue(for: key)
        do {
            return try encodedValue.map {
                try JSONDecoder().decode([T].self, from: $0)
            } ?? []
        } catch {
            throw FXKeychainProviderError(
                code: .data2CodableConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to codable"
            )
        }
    }

    public func getValue(for key: Key) throws -> Data? {
        try self.accessQueue.sync {
            var query = self.keychainQueryable.query
            query[String(kSecMatchLimit)] = kSecMatchLimitOne
            query[String(kSecReturnAttributes)] = kCFBooleanTrue
            query[String(kSecReturnData)] = kCFBooleanTrue
            query[String(kSecAttrAccount)] = key.rawValue

            var queryResult: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &queryResult)

            switch status {
            case errSecSuccess:
                guard
                    let queriedItem = queryResult as? [String: Any],
                    let passwordData = queriedItem[String(kSecValueData)] as? Data
                else {
                    throw FXKeychainProviderError(
                        code: .dataRetrieving,
                        localizedDescription: "Data corrupted",
                        systemMessage: "Cannot retreive binary data"
                    )
                }
                return passwordData

            case errSecItemNotFound:
                return nil

            default:
                throw self.error(from: status)
            }
        }
    }

    public func removeValue(for key: Key, completion: ((Error?) -> Void)? = nil) {
        self.accessQueue.async(flags: .barrier) {
            var query = self.keychainQueryable.query
            query[String(kSecAttrAccount)] = key.rawValue

            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                completion?(self.error(from: status))
                return
            }
            completion?(nil)
        }
    }

    public func removeAllValues(completion: ((Error?) -> Void)? = nil) {
        self.accessQueue.async(flags: .barrier) {
            let query = self.keychainQueryable.query

            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                completion?(self.error(from: status))
                return
            }
            completion?(nil)
        }
    }

    // MARK: Private

    // MARK: - Private Properties

    private let keychainQueryable: FXKeychainQueryable
    private let accessQueue = DispatchQueue(label: "com.foundationx.keychainAccess", attributes: .concurrent)

    // MARK: - Private Methods

    private func error(from status: OSStatus) -> FXKeychainProviderError {
        let message: String?
        if #available(iOS 11.3, *) {
            message = SecCopyErrorMessageString(status, nil) as String?
        } else {
            message = "OSStatus: \(status)"
        }

        return .init(
            code: .unknown,
            localizedDescription: message,
            systemMessage: message
        )
    }
}

// MARK: - Convenience Init

public extension FXKeychainProvider {
    /// Initializes Keychain with a generic password type (kSecClassGenericPassword).
    /// - Parameters:
    ///   - service: A key whose value is a string indicating the item's service.
    ///   - accessGroup: A key whose value is a string indicating the access group an item is in.
    convenience init(
        service: String,
        accessGroup: String? = nil
    ) {
        let queryable = FXGenericKeychainPasswordQueryable(
            service: service,
            accessGroup: accessGroup
        )
        self.init(keychainQueryable: queryable)
    }
}

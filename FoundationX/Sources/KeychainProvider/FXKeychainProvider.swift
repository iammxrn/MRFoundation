import Foundation
import Security

public protocol FXKeychainProviderKey: RawRepresentable where RawValue == String {}

public final class FXKeychainProvider<Key: FXKeychainProviderKey> {
    // MARK: Lifecycle

    // MARK: - Init

    public init(keychainQueryable: FXKeychainQueryable) {
        self.keychainQueryable = keychainQueryable
    }

    // MARK: Private

    // MARK: - Private Properties

    private let keychainQueryable: FXKeychainQueryable

    // MARK: - Private Methods

    private func error(from status: OSStatus) -> FXKeychainProviderError {
        let message = SecCopyErrorMessageString(status, nil) as String?

        return .init(
            code: .unknown,
            localizedDescription: message,
            systemMessage: message
        )
    }
}

// MARK: - GET

public extension FXKeychainProvider {
    func getStringValue(for key: Key) throws -> String? {
        guard let data = try getDataValue(for: key) else { return nil }

        guard let value = String(data: data, encoding: .utf8) else {
            throw FXKeychainProviderError(
                code: .data2StringConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to string"
            )
        }

        return value
    }

    func getValue<T: Codable>(for key: Key) throws -> T? {
        guard let data = try getDataValue(for: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw FXKeychainProviderError(
                code: .data2CodableConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to codable"
            )
        }
    }

    func getDataValue(for key: Key) throws -> Data? {
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

// MARK: - SET

public extension FXKeychainProvider {
    func setValue(_ value: some Codable, for key: Key) async throws {
        guard let encodedValue = try? JSONEncoder().encode(value) else {
            throw FXKeychainProviderError(
                code: .codable2DataConversion,
                localizedDescription: "Invalid value: \(value)",
                systemMessage: "Cannot convert value: \(value) to binary data"
            )
        }
        try await self.setValue(encodedValue, for: key)
    }

    func setValue(_ value: Data, for key: Key) async throws {
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
                throw self.error(from: status)
            }

        case errSecItemNotFound:
            query[String(kSecValueData)] = value

            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw self.error(from: status)
            }

        default:
            throw self.error(from: status)
        }
    }
}

// MARK: - REMOVE

public extension FXKeychainProvider {
    func removeValue(for key: Key) async throws {
        var query = self.keychainQueryable.query
        query[String(kSecAttrAccount)] = key.rawValue

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw self.error(from: status)
        }
    }

    func removeAllValues() async throws {
        let query = self.keychainQueryable.query

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw self.error(from: status)
        }
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

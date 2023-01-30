//
//  KeychainProvider.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 24.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation
import Security


public protocol MRKeychainProviderKey: RawRepresentable where RawValue == String {}

open class MRKeychainProvider<Key: MRKeychainProviderKey> {
    
    
    // MARK: - Private Properties
    
    private let keychainQueryable: MRKeychainQueryable
    
    
    // MARK: - Init
    
    public init(keychainQueryable: MRKeychainQueryable) {
        self.keychainQueryable = keychainQueryable
    }
    
    
    // MARK: - Public Methods
    
    public func setValue(_ value: String, for key: Key) throws {
        guard let encodedValue = value.data(using: .utf8) else {
            throw MRKeychainProviderError(
                code: .string2DataConversion,
                localizedDescription: "Invalid value: \(value)",
                systemMessage: "Cannot convert value: \(value) to binary data"
            )
        }
        try setValue(encodedValue, for: key)
    }
    
    public func setValue<T: Codable>(_ value: T, for key: Key) throws {
        guard let encodedValue = try? JSONEncoder().encode(value) else {
            throw MRKeychainProviderError(
                code: .codable2DataConversion,
                localizedDescription: "Invalid value: \(value)",
                systemMessage: "Cannot convert value: \(value) to binary data"
            )
        }
        try setValue(encodedValue, for: key)
    }
    
    public func setValues<T: Codable>(_ values: [T], for key: Key) throws {
        guard let encodedValue = try? JSONEncoder().encode(values) else {
            throw MRKeychainProviderError(
                code: .codable2DataConversion,
                localizedDescription: "Invalid values: \(values)",
                systemMessage: "Cannot convert value: \(values) to binary data"
            )
        }
        try setValue(encodedValue, for: key)
    }
    
    public func setValue(_ value: Data, for key: Key) throws {
        var query = keychainQueryable.query
        query[String(kSecAttrAccount)] = key.rawValue
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[String(kSecValueData)] = value
            
            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(from: status)
            }
            
        case errSecItemNotFound:
            query[String(kSecValueData)] = value
            
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(from: status)
            }
            
        default:
            throw error(from: status)
        }
    }
    
    public func getValue(for key: Key) throws -> String? {
        guard let encodedValue: Data = try getValue(for: key) else {
            return nil
        }
        
        guard let value = String(data: encodedValue, encoding: .utf8) else {
            throw MRKeychainProviderError(
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
            throw MRKeychainProviderError(
                code: .data2CodableConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to codable"
            )
        }
    }
    
    public func getValues<T: Codable>(for key: Key) throws -> [T]? {
        let encodedValue: Data? = try getValue(for: key)
        do {
            return try encodedValue.map {
                try JSONDecoder().decode([T].self, from: $0)
            }
        } catch {
            throw MRKeychainProviderError(
                code: .data2CodableConversion,
                localizedDescription: "Data corrupted",
                systemMessage: "Cannot convert binary data to codable"
            )
        }
    }
    
    public func getValue(for key: Key) throws -> Data? {
        var query = keychainQueryable.query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = key.rawValue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        switch status {
        case errSecSuccess:
            guard
                let queriedItem = queryResult as? [String: Any],
                let passwordData = queriedItem[String(kSecValueData)] as? Data
            else {
                throw MRKeychainProviderError(
                    code: .dataRetrieving,
                    localizedDescription: "Data corrupted",
                    systemMessage: "Cannot retreive binary data"
                )
            }
            return passwordData
            
        case errSecItemNotFound:
            return nil
            
        default:
            throw error(from: status)
        }
    }
    
    public func removeValue(for key: Key) throws {
        var query = keychainQueryable.query
        query[String(kSecAttrAccount)] = key.rawValue
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }
    
    public func removeAllValues() throws {
        let query = keychainQueryable.query
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }
    
    
    // MARK: - Private Methods
    
    private func error(from status: OSStatus) -> MRKeychainProviderError {
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

extension MRKeychainProvider {
    
    /// Initializes Keychain with a generic password type (kSecClassGenericPassword).
    /// - Parameters:
    ///   - service: A key whose value is a string indicating the item's service.
    ///   - accessGroup: A key whose value is a string indicating the access group an item is in.
    public convenience init(
        service: String,
        accessGroup: String? = nil
    ) {
        let queryable = MRGenericKeychainPasswordQueryable(
            service: service,
            accessGroup: accessGroup
        )
        self.init(keychainQueryable: queryable)
    }
    
}

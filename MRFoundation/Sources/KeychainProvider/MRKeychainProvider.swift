//
//  KeychainProvider.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 24.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import MRFoundation
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
        guard let encodedPassword = value.data(using: .utf8) else {
            throw MRKeychainProviderError(
                code: .string2DataConversion,
                localizedDescription: "Invalid value: \(value)",
                systemMessage: "Cannot convert value: \(value) to binary data"
            )
        }
        
        var query = keychainQueryable.query
        query[String(kSecAttrAccount)] = key.rawValue
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[String(kSecValueData)] = encodedPassword
            
            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(from: status)
            }
            
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedPassword
            
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(from: status)
            }
            
        default:
            throw error(from: status)
        }
    }
    
    public func getValue(for key: Key) throws -> String? {
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
                let passwordData = queriedItem[String(kSecValueData)] as? Data,
                let password = String(data: passwordData, encoding: .utf8)
            else {
                throw MRKeychainProviderError(
                    code: .data2StringConversion,
                    localizedDescription: "Data corrupted",
                    systemMessage: "Cannot convert binary data to string"
                )
            }
            return password
            
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

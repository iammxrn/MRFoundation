//
//  MRUserDefaultsProvider.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

/// MRUserDefaultsProviderKey
///
/// A protocol that defines a key type that can be used with MRUserDefaultsProvider.
/// ```swift
/// enum MyUserDefaultsProviderKey: String, MRUserDefaultsProviderKey {
///    case myProperty
///    case anotherProperty
/// }
/// ```
public protocol MRUserDefaultsProviderKey: RawRepresentable where RawValue == String {}

/// MRUserDefaultsProvider
///
/// A class that provides a simple interface for interacting with UserDefaults.
open class MRUserDefaultsProvider<Key: MRUserDefaultsProviderKey> {

    // MARK: - Private Properties

    private let userDefaults: UserDefaults

    // MARK: - Pubci Init

    /// Initializes a new MRUserDefaultsProvider instance.
    ///
    /// - Parameters:
    ///   - userDefaults: The UserDefaults instance to use for persistence.
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods

    /// Persists data for a given key.
    ///
    /// - Parameters:
    ///   - data: The data to persist.
    ///   - key: The key to associate the data with.
    public func persist(_ data: Any, for key: Key) {
        userDefaults.set(data, forKey: key.rawValue)
        userDefaults.synchronize()
    }

    /// Erases data for a given key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the data to erase.
    public func eraseData(for key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
        userDefaults.synchronize()
    }

    /// Fetches data for a given key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the data to fetch.
    /// - Returns: The fetched data, or nil if no data is associated with the key.
    public func fetchData<T>(for key: Key) -> T? {
        guard let object = userDefaults.object(forKey: key.rawValue) else { return nil }

        return object as? T
    }
}

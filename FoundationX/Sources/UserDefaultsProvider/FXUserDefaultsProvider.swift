import Foundation

/// FXUserDefaultsProviderKey
///
/// A protocol that defines a key type that can be used with FXUserDefaultsProvider.
/// ```swift
/// enum MyUserDefaultsProviderKey: String, FXUserDefaultsProviderKey {
///    case myProperty
///    case anotherProperty
/// }
/// ```
public protocol FXUserDefaultsProviderKey: RawRepresentable where RawValue == String {}

/// FXUserDefaultsProvider
///
/// A class that provides a simple interface for interacting with UserDefaults.
open class FXUserDefaultsProvider<Key: FXUserDefaultsProviderKey> {
    // MARK: Lifecycle

    // MARK: - Pubci Init

    /// Initializes a new FXUserDefaultsProvider instance.
    ///
    /// - Parameters:
    ///   - userDefaults: The UserDefaults instance to use for persistence.
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: Public

    // MARK: - Public Methods

    /// Persists data for a given key.
    ///
    /// - Parameters:
    ///   - data: The data to persist.
    ///   - key: The key to associate the data with.
    public func persist(_ data: Any?, for key: Key) {
        self.userDefaults.set(data, forKey: key.rawValue)
        self.userDefaults.synchronize()
    }

    /// Persists codable value for a given key.
    ///
    /// - Parameters:
    ///   - value: The value to persist.
    ///   - key: The key to associate the value with.
    public func persistValue(_ value: some Codable, for key: Key) throws {
        let encodedData = try JSONEncoder().encode(value)
        self.persist(encodedData, for: key)
    }

    /// Persists codable values for a given key.
    ///
    /// - Parameters:
    ///   - values: The values to persist.
    ///   - key: The key to associate the values with.
    public func persistValues(_ values: [some Codable], for key: Key) throws {
        let encodedData = try JSONEncoder().encode(values)
        self.persist(encodedData, for: key)
    }

    /// Erases data for a given key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the data to erase.
    public func eraseData(for key: Key) {
        self.userDefaults.removeObject(forKey: key.rawValue)
        self.userDefaults.synchronize()
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

    /// Fetches value for a given key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the value to fetch.
    /// - Returns: The fetched value, or nil if no data is associated with the key.
    public func fetchValue<T: Codable>(for key: Key) throws -> T? {
        let object: Data? = self.fetchData(for: key)
        return try object.map {
            try JSONDecoder().decode(T.self, from: $0)
        }
    }

    /// Fetches values for a given key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the values to fetch.
    /// - Returns: The fetched values, or empty if no data is associated with the key.
    public func fetchValues<T: Codable>(for key: Key) throws -> [T] {
        let object: Data? = self.fetchData(for: key)
        return try object.map {
            try JSONDecoder().decode([T].self, from: $0)
        } ?? []
    }

    // MARK: Private

    // MARK: - Private Properties

    private let userDefaults: UserDefaults
}

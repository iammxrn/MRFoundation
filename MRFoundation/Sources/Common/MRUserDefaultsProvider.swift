//
//  MRUserDefaultsProvider.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


public protocol MRUserDefaultsProviderKey: RawRepresentable where RawValue == String {}

open class MRUserDefaultsProvider<Key: MRUserDefaultsProviderKey> {
    
    
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults
    
    
    // MARK: - Init
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    
    // MARK: - Public Methods
    
    public func persist(_ data: Any, for key: Key) {
        userDefaults.set(data, forKey: key.rawValue)
        userDefaults.synchronize()
    }
    
    public func eraseData(for key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
        userDefaults.synchronize()
    }
    
    public func fetchData<T>(for key: Key) -> T? {
        guard let object = userDefaults.object(forKey: key.rawValue) else { return nil }
        
        return object as? T
    }
}


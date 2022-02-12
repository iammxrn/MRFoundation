//
//  UserDefaultsManager.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


public struct UserDefaultsManagerKey {
    
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
}

public enum UserDefaultsManager {
    
    public static func persist(_ data: Any, for key: UserDefaultsManagerKey) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(data, forKey: key.value)
        userDefaults.synchronize()
    }
    
    public static func eraseData(for key: UserDefaultsManagerKey) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: key.value)
        userDefaults.synchronize()
    }
    
    public static func fetchData<T>(for key: UserDefaultsManagerKey) -> T? {
        let userDefaults = UserDefaults.standard
        
        guard let object = userDefaults.object(forKey: key.value) else { return nil }
        
        return object as? T
    }
}


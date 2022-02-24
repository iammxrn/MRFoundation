//
//  MRGenericKeychainPasswordQueryable.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 24.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation
import Security


struct MRGenericKeychainPasswordQueryable: MRKeychainQueryable {
    
    let service: String
    let accessGroup: String?
    
    var query: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[String(kSecAttrAccessGroup)] = accessGroup
        }
        #endif
        return query
    }
    
    init(
        service: String,
        accessGroup: String? = nil
    ) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

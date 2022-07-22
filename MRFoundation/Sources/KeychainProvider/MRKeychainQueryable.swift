//
//  MRKeychainQueryable.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 24.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


public protocol MRKeychainQueryable {
    
    var query: [String: Any] { get }
    
}

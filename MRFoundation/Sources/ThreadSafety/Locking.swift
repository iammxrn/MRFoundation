//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


protocol Locking {
    
    @discardableResult
    func readLocked<Result>(_ action: () throws -> Result) rethrows -> Result
    
    @discardableResult
    func writeLocked<Result>(_ action: () throws -> Result) rethrows -> Result
}

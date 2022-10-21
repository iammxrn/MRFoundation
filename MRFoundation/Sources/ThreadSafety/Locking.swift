//
//  ReadWriteAtomic.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

protocol Locking {
    
    func rd_lock()
    
    func rd_unlock()
    
    func wr_lock()
    
    func wr_unlock()
    
}

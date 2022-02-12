//
//  Comparable+Extension.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


// MARK: - Range clamping

extension Comparable {
    
    /// Range clamping
    ///
    /// - Parameter range: specified range
    /// - Returns: A number based on specified range. If the number is less than the lower bound,
    /// the result will be the value of the lower bound, if higher - upper.
    func clamped(to range: ClosedRange<Self>) -> Self {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }
    
    fileprivate func clamped(min lower: Self, max upper: Self) -> Self {
        return min(max(self, lower), upper)
    }
}

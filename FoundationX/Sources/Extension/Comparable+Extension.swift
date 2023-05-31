import Foundation

// MARK: - Range clamping

extension Comparable {
    /// Range clamping
    ///
    /// - Parameter range: specified range
    /// - Returns: A number based on specified range. If the number is less than the lower bound,
    /// the result will be the value of the lower bound, if higher - upper.
    public func clamped(to range: ClosedRange<Self>) -> Self {
        self.clamped(min: range.lowerBound, max: range.upperBound)
    }

    private func clamped(min lower: Self, max upper: Self) -> Self {
        min(max(self, lower), upper)
    }
}

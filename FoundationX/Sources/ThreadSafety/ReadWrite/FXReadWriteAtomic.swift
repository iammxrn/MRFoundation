import Foundation

/// Atomic based on ReadWriteLock.
///
/// - Important: This property wrapper guarantees that the wrapped value will be thread-safe, as well as the absence of any side effects.
///
@propertyWrapper
public final class FXReadWriteAtomic<Value>: Atomic {
    // MARK: Lifecycle

    // MARK: - Init

    public init(wrappedValue: Value) {
        self._unsafeWrappedValue = wrappedValue
    }

    // MARK: Public

    // MARK: - Public Properties

    public var wrappedValue: Value {
        get {
            value
        } _modify {
            yield &value
        }
    }

    public var projectedValue: FXReadWriteAtomic<Value> { self }

    // MARK: Internal

    // MARK: - Internal Properties

    let _lock = FXReadWriteLock()

    var _unsafeWrappedValue: Value
}

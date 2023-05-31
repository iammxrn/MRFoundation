import Foundation

/// The FXDispatchTimer class provides a simple way to execute a block of code at set intervals.
///
/// - Parameters:
///   - timeInterval: The time interval at which the eventHandler block should be executed.
public final class FXDispatchTimer {
    // MARK: Lifecycle

    // MARK: - Init

    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    // MARK: Public

    // MARK: - Public Properties

    /// The time interval at which the eventHandler block should be executed.
    public let timeInterval: TimeInterval

    /// The block of code to be executed at set intervals.
    public var eventHandler: ((_ timer: FXDispatchTimer) -> Void)?

    // MARK: - Public Methods

    /// Resumes the timer.
    public func resume() {
        guard self.state != .resumed else { return }

        self.state = .resumed
        self.timer.resume()
    }

    /// Suspends the timer.
    public func suspend() {
        guard self.state != .suspended else { return }

        self.state = .suspended
        self.timer.suspend()
    }

    // MARK: Private

    // MARK: - Private Enums

    private enum State {
        case suspended
        case resumed
    }

    // MARK: - Private Properties

    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            self.eventHandler?(self)
        }
        return timer
    }()

    private var state: State = .suspended
}

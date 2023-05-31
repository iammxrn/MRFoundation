import Foundation
import os

public protocol FXLoggingGroup: Hashable, CaseIterable, RawRepresentable where RawValue == Int {
    var consoleTitle: String { get }
}

public protocol FXLogLevel: RawRepresentable where RawValue == Int {
    var rawValue: Int { get }

    var osLogType: OSLogType { get }
}

public final class FXLog<LoggingGroup: FXLoggingGroup, LogLevel: FXLogLevel> {
    // MARK: Lifecycle

    // MARK: - Init

    public init(
        subsystemName: String,
        minimumLogLevel: LogLevel
    ) {
        self.subsystemName = subsystemName
        self.minimumLogLevel = minimumLogLevel
    }

    // MARK: Public

    // MARK: - Public Properties

    public private(set) var minimumLogLevel: LogLevel

    // MARK: - Public Methods

    /// Enables specific logging groups.
    ///
    /// - Parameter loggingGroups: An array of logging groups to be enabled.
    /// You can also pass **.all**, **.allExcept**  or **.none**.
    public func setEnabledLoggingGroups(_ loggingGroups: [LoggingGroup]) {
        self.enabledLoggingGroups = Dictionary(
            uniqueKeysWithValues: loggingGroups.map {
                ($0.rawValue, OSLog(
                    subsystem: self.subsystemName,
                    category: $0.consoleTitle
                ))
            }
        )
    }

    public func setMinimumLogLevel(_ level: LogLevel) {
        self.minimumLogLevel = level
    }

    public func log(
        _ message: String,
        level: LogLevel,
        loggingGroup: LoggingGroup,
        file: String = #file,
        isSecured: Bool = false
    ) {
        #if DEBUG
        guard level.rawValue >= self.minimumLogLevel.rawValue else { return }
        #endif

        let fullMessage = "[\(callerClassName(file: file))] \(message)"

        let formatString: StaticString
        #if DEBUG
        formatString = "%{public}@"
        #else
        formatString = isSecured ? "%{private}@" : "%{public}@"
        #endif

        let log = self.osLog(for: loggingGroup)
        let type = level.osLogType

        os_log(
            formatString,
            log: log,
            type: type,
            fullMessage as NSString
        )
    }

    // MARK: Private

    // MARK: - Private Properties

    private var enabledLoggingGroups: [Int: OSLog] = [:]

    private let subsystemName: String

    // MARK: - Private Methods

    private func osLog(for loggingGroup: LoggingGroup) -> OSLog {
        self.enabledLoggingGroups[loggingGroup.rawValue] ?? .disabled
    }
}

public func callerClassName(file: String = #file) -> String {
    file.between("/", ".swift") ?? ""
}

public extension Array where Element: FXLoggingGroup {
    static var all: [Element] { Element.allCases as! [Element] }

    static var none: [Element] { [] }

    static func allExcept(_ excludedLoggingGroups: [Element]) -> [Element] {
        Array(Set(self.all).subtracting(excludedLoggingGroups))
    }

    static func allExcept(_ excludedLoggingGroup: Element) -> [Element] {
        self.all.filter { $0 != excludedLoggingGroup }
    }
}

private extension String {
    /// Search from end of source string. SomeFile.swift <--
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left, options: .backwards),
            let rightRange = range(of: right, options: .backwards),
            leftRange.upperBound <= rightRange.lowerBound
        else {
            return nil
        }

        let sub = self[leftRange.upperBound...]

        guard let closestToLeftRange = sub.range(of: right) else { return nil }

        return String(sub[..<closestToLeftRange.lowerBound])
    }
}

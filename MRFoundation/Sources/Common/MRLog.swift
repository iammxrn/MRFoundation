//
//  MRLog.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation
import os


public protocol MRLoggingGroup: Hashable, CaseIterable, RawRepresentable where RawValue == Int {
    
    var consoleTitle: String { get }
}

public protocol MRLogLevel: RawRepresentable where RawValue == Int {
    
    var rawValue: Int { get }
    
    var osLogType: OSLogType { get }
}

public final class MRLog<LoggingGroup: MRLoggingGroup, LogLevel: MRLogLevel> {
   
    
    // MARK: - Public Properties
    
    public private(set) var minimumLogLevel: LogLevel
    
    
    // MARK: - Private Properties

    private var enabledLoggingGroups: [Int: OSLog] = [:]
    
    private let subsystemName: String


    // MARK: - Init
    
    public init(
        subsystemName: String,
        minimumLogLevel: LogLevel
    ) {
        self.subsystemName = subsystemName
        self.minimumLogLevel = minimumLogLevel
    }
    
    
    // MARK: - Public Methods

    /// Enables specific logging groups.
    ///
    /// - Parameter loggingGroups: An array of logging groups to be enabled.
    /// You can also pass **.all**, **.allExcept**  or **.none**.
    public func setEnabledLoggingGroups(_ loggingGroups: [LoggingGroup]) {
        enabledLoggingGroups = Dictionary(
            uniqueKeysWithValues: loggingGroups.map {
                ($0.rawValue, OSLog(subsystem: subsystemName,
                                    category: $0.consoleTitle))
            }
        )
    }
    
    public func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    public func log(
        _ message: String,
        level: LogLevel,
        loggingGroup: LoggingGroup,
        file: String = #file,
        isSecured: Bool = false
    ) {
        
        #if DEBUG
        guard level.rawValue >= minimumLogLevel.rawValue else { return }
        #endif
        
        let fullMessage: String = "[\(callerClassName(file: file))] \(message)"

        let formatString: StaticString
        #if DEBUG
            formatString = "%{public}@"
        #else
            formatString = isSecured ? "%{private}@" : "%{public}@"
        #endif
        
        let log = osLog(for: loggingGroup)
        let type = level.osLogType

        os_log(formatString,
               log: log,
               type: type,
               fullMessage as NSString)
    }
    
    
    // MARK: - Private Methods
    
    private func osLog(for loggingGroup: LoggingGroup) -> OSLog {
        enabledLoggingGroups[loggingGroup.rawValue] ?? .disabled
    }
    
}

public func callerClassName(file: String = #file) -> String {
    file.between("/", ".swift") ?? ""
}

extension Array where Element: MRLoggingGroup {
    
    public static var all: [Element] { Element.allCases as! [Element] }
    
    public static var none: [Element] { [] }
    
    public static func allExcept(_ excludedLoggingGroups: [Element]) -> [Element] {
        Array(Set(self.all).subtracting(excludedLoggingGroups))
    }
    
    public static func allExcept(_ excludedLoggingGroup: Element) -> [Element] {
        self.all.filter { $0 != excludedLoggingGroup }
    }
}


extension String {

    /// Search from end of source string. SomeFile.swift <--
    fileprivate func between(_ left: String, _ right: String) -> String? {
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


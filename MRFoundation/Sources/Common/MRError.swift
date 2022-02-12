//
//  MRError.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


public protocol MRErrorCode: RawRepresentable where RawValue == Int {}


public protocol MRErrorProtocol: NSError {
    
    /// Returns error short codes chain from all levels
    ///
    /// - Returns: error short codes
    func shortCodesChain() -> String
    
    /// Full event chain from all levels, includes errors short codes and full errors description
    ///
    /// - Returns: string with errors short codes and full errors description
    func eventChain() -> String
    
    /// Short domain name (ex. Network -> NE)
    ///
    /// - Returns: short domain name
    func domainShortName() -> String
    
    /// Error short code (ex. NE13)
    var shortCode: String { get }
    
    /// Error code human-readable description
    var errorCodeName: String { get }
    
    /// A human-readable message string summarizing the reason for the exception
    var systemMessage: String? { get }
    
    /// Additional info which may be used to describe the error further
    var userInfo: [String: Any] { get }
    
    /// A user-readable message string summarizing the reason for the exception
    var localizedDescription: String { get }
    
}

open class MRError<ErrorCode: MRErrorCode>: NSError, MRErrorProtocol {
    
    
    // MARK: - Public Properties
    
    override public final var domain: String {
        String(describing: type(of: self))
    }
    
    /// Error code for the error
    public final var errorCode: ErrorCode {
        ErrorCode(rawValue: code)!
    }
    
    public final var errorCodeName: String {
        String(describing: errorCode)
    }
    
    public final var shortCode: String {
        domainShortName() + "\(errorCode.rawValue)"
    }
    
    public final var systemMessage: String? {
        userInfo[NSLocalizedFailureReasonErrorKey] as? String
    }
    
    override public final var localizedDescription: String {
        var _localizedDescription = userInfo[NSLocalizedDescriptionKey] as? String ?? ""
    
        if let underlyingError = userInfo[NSUnderlyingErrorKey] as? MRErrorProtocol {
            _localizedDescription = underlyingError.localizedDescription
        }
        
        return _localizedDescription
    }
    
    
    // MARK: - Private Properties
    
    private var callerName: String
    private var callerLine: Int
    
    
    // MARK: - Init
    
    public required init(
        code: ErrorCode,
        localizedDescription: String? = nil,
        systemMessage: String? = nil,
        underlyingError: Error? = nil,
        callerName: String = #function,
        callerLine: Int = #line
    ) {
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = localizedDescription
        userInfo[NSLocalizedFailureReasonErrorKey] = systemMessage
        userInfo[NSUnderlyingErrorKey] = underlyingError
        
        self.callerName = callerName
        self.callerLine = callerLine
        
        super.init(
            domain: String(describing: type(of: self)),
            code: code.rawValue,
            userInfo: userInfo
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Methods
    
    open func domainShortName() -> String {
        assertionFailure("Abstract class has not been implemented")
        return "UnknownDomain"
    }
    
    public final func eventChain() -> String {
        var initialShortCode: String = "\n"
            + "============================="
            + "\n"
            + "Error Code: "
            + "\(shortCode)"
            + "\n"
            + "Error Code Name: "
            + "\(errorCodeName)"
            + "\n"
            + "Method: "
            + "\(callerName)"
            + "\n"
            + "System Message: "
            + "\(systemMessage ?? "No System Message ")"
            + "\n"
            + "Localized Description: "
            + "\(localizedDescription)"
            + "\n"
            + "============================="
            + "\n"

        if let underlyingError = userInfo[NSUnderlyingErrorKey] {
            switch underlyingError {
            case let mrError as MRErrorProtocol:
                initialShortCode.append("Underlying Error:" + "\n" + mrError.eventChain())
            case let error as Error:
                let stringErrorDescription: String = "Underlying Error:"
                + "\n"
                + "============================="
                + "\n"
                + "Localized Description: "
                + "\(error.localizedDescription)"
                + "\n"
                + "Full Error: "
                + "\(error)"
                + "\n"
                + "============================="
                + "\n"
                initialShortCode.append(stringErrorDescription)
            default:
                break
            }
        }

        return initialShortCode
    }
    
    public final func shortCodesChain() -> String {
        var initialLink = shortCode
        
        if let underlyingError = userInfo[NSUnderlyingErrorKey] as? MRErrorProtocol {
            initialLink.append("-" + underlyingError.shortCodesChain())
        }
        
        return initialLink
    }
}



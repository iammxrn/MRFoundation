//
//  String+Extension.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 17.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


// MARK: - Localization

extension String {
    
    /// Returns a localized string with empty comment.
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string using a given format a template.
    public static func localized(_ format: String, _ arguments: CVarArg...) -> String {
        return String(format: format.localized, locale: Locale.current, arguments: arguments)
    }
    
}


// MARK: - Hash

extension String {

    /// DJB Hash function
    ///
    /// - Warning: Keep in mind that DJB hash function is not designed to be collision-resistant,
    /// it's not considered to be a secure hash function and should not be used for cryptographic purposes.
    /// If collision resistance is important for your use case, then you should use a cryptographic hash function like SHA-256.
    ///
    /// - Returns: A UInt64 value representing the hash of the string.
    public var permanentDJBHash: UInt64 {
        var result: UInt64 = .djbPrimeNumber
        let buf = [UInt8](self.utf8)
        for b in buf {
            result = UInt64.shiftCount * (result & 0x00ffffffffffffff) + UInt64(b) // ~7 bits mask
        }
        return result
    }
}

extension UInt64 {
    
    /// See the reason below.
    /// https://stackoverflow.com/questions/10696223/reason-for-the-number-5381-in-the-djb-hash-function/13809282#13809282
    fileprivate static var djbPrimeNumber: UInt64 { 5_381 }
    
    fileprivate static var shiftCount: UInt64 { 127 }
}


extension String {
    
    static var defaultDomain: String { "com.mxrn.MRFoundation" }

}

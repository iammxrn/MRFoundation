//
//  MRKeychainProviderError.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 24.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation


public enum MRKeychainProviderErrorCode: Int, MRErrorCode {
    case unknown = 0
    case string2DataConversion = 1
    case data2StringConversion = 2
    case dataRetrieving = 3
    case codable2DataConversion = 4
    case data2CodableConversion = 5
}

public final class MRKeychainProviderError: MRError<MRKeychainProviderErrorCode> {

    public override func domainShortName() -> String {
        "MR_KP"
    }
}

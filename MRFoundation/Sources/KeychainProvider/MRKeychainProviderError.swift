//
//  MRKeychainProviderError.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 24.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import MRFoundation


public enum MRKeychainProviderErrorCode: Int, MRErrorCode {
    case unknown = 0
    case string2DataConversion = 1
    case data2StringConversion = 2
}

public final class MRKeychainProviderError: MRError<MRKeychainProviderErrorCode> {

    public override func domainShortName() -> String {
        "MR_KP"
    }
}

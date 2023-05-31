import Foundation

public enum FXKeychainProviderErrorCode: Int, FXErrorCode {
    case unknown = 0
    case string2DataConversion = 1
    case data2StringConversion = 2
    case dataRetrieving = 3
    case codable2DataConversion = 4
    case data2CodableConversion = 5
}

public final class FXKeychainProviderError: FXError<FXKeychainProviderErrorCode> {
    override public func domainShortName() -> String {
        "FX_KP"
    }
}

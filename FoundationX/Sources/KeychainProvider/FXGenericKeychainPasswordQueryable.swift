import Foundation
import Security

struct FXGenericKeychainPasswordQueryable: FXKeychainQueryable {
    // MARK: Lifecycle

    init(
        service: String,
        accessGroup: String? = nil
    ) {
        self.service = service
        self.accessGroup = accessGroup
    }

    // MARK: Internal

    let service: String
    let accessGroup: String?

    var query: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = self.service
        #if !targetEnvironment(simulator)
        if let accessGroup {
            query[String(kSecAttrAccessGroup)] = accessGroup
        }
        #endif
        return query
    }
}

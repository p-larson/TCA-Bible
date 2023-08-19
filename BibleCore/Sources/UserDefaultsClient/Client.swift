import ComposableArchitecture
import Foundation

public struct UserDefaultsClient {
    public var get: @Sendable (_ key: String) async throws -> (Data?)
    public var set: @Sendable (_ data: Data, _ key: String) async throws -> ()
}

extension DependencyValues {
    public var defaults: UserDefaultsClient {
        get {
            self[UserDefaultsClient.self]
        }
        
        set {
            self[UserDefaultsClient.self] = newValue
        }
    }
}

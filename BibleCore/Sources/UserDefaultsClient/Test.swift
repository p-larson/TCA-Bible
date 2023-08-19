import ComposableArchitecture
import XCTestDynamicOverlay

extension UserDefaultsClient: TestDependencyKey {
    public static let testValue: UserDefaultsClient = {
       UserDefaultsClient(
            get: unimplemented("\(Self.self).get"),
            set: unimplemented("\(Self.self).baseUrl")
       )
    }()
}


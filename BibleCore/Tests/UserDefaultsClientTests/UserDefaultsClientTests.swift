import XCTest

@testable import UserDefaultsClient

final class UserDefaultsClientTests: XCTestCase {

    func testWrite() {
        // We only be tseting the real thing here, like a boss.
        
        let client = UserDefaultsClient.liveValue
    }

}

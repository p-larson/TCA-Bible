#if os(iOS)

import XCTest
import ComposableArchitecture
import SnapshotTesting
import ReaderCore
import SwiftUI
import UIKit

final class MobileSnapshotTests: XCTestCase {
    
    func testMobile() {
        let store = Store(initialState: MobileReader.State()) {
            MobileReader()
        }
        
        store.send(.page(.task))
        
        let view = ReaderView(store: store)
        
        let vc = UIHostingController(rootView: view)
        
        assertSnapshot(matching: vc, as: .image(on: .iPhone12ProMax))
    }
}

#endif

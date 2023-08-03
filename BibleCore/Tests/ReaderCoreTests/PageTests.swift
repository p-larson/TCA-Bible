//
//  ReaderCoreTests.swift
//  
//
//  Created by Peter Larson on 8/3/23.
//

import XCTest
import ComposableArchitecture
import BibleCore
@testable import ReaderCore

final class PageTests: XCTestCase {
    
    @MainActor
    func testTask() async {
        let store = TestStore(
            initialState: Page.State(),
            reducer: {
                Page()._printChanges()
            }
        )
        
        await store.send(.task)

        await store.receive(.open(.mock, .mock, [.mock]), timeout: .seconds(10)) {
            $0.book = .mock
            $0.chapter = .mock
            $0.verses = [.mock]
        }
    }
}

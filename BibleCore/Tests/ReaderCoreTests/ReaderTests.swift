//
//  ReaderTests.swift
//  
//
//  Created by Peter Larson on 8/3/23.
//

import XCTest
import ComposableArchitecture
import BibleCore
@testable import ReaderCore

final class ReaderTests: XCTestCase {
    @MainActor func testOpenBible() async {
        let store = TestStore(
            initialState: Reader.State(isDirectoryOpen: false),
            reducer: {
                Reader()
            }
        )
        
        await store.send(.openDirectory)
    }
}

//
//  ReaderTests.swift
//  
//
//  Created by Peter Larson on 8/3/23.
//

import XCTest
import ComposableArchitecture
import BibleCore
import DirectoryCore
@testable import ReaderCore

final class ReaderTests: XCTestCase {
    @MainActor func testOpenBible() async {
        let store = TestStore(
            initialState: Reader.State(isDirectoryOpen: false),
            reducer: {
                Reader()
            }
        )
        
        await store.send(.openDirectory) {
            $0.isDirectoryOpen = true
        }
        
        await store.send(.directory(.task))
        
        
        await store.receive(.directory(.load(.success([.mock]))), timeout: .seconds(10)) {
            $0.directory.sections = [.mock]
        }
    }
}

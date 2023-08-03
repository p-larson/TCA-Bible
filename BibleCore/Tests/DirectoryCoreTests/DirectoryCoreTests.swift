//
//  DirectoryCoreTests.swift
//  
//
//  Created by Peter Larson on 8/3/23.
//

import XCTest
import ComposableArchitecture
import BibleCore
@testable import DirectoryCore

final class DirectoryCoreTests: XCTestCase {

    @MainActor
    func testSectionToggle() async {
        let store = TestStore(initialState: Section.State.mock, reducer:  {
            Section()
        }) {
            // Probably shouldn't do this right?
            $0.bible = .liveValue
        }
        
        await store.send(.toggle) {
            $0.isExpanded = true
        }
        
        let chapters = (1 ... 50).map(Chapter.init(id:))
        
        await store.receive(.load(.success(chapters)), timeout: .seconds(10)) {
            $0.chapters = chapters
        }
        
        await store.send(.toggle) {
            $0.isExpanded = false
        }
    }
}





































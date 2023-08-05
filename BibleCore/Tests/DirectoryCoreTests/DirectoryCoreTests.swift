//
//  DirectoryCoreTests.swift
//  
//
//  Created by Peter Larson on 8/3/23.
//

import XCTest
import ComposableArchitecture
import BibleClient
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
    
    @MainActor func testOpenAnotherBook() async {
        let store = TestStore(initialState: Directory.State.mock, reducer:  {
            Directory()
        })
        
        await store.send(.task)
        
        await store.receive(.load(.success(.mock))) {
            $0.sections = IdentifiedArray(
                uniqueElements: [Book].mock.map(Section.State.init(book:))
            )
        }
        
        await store.send(.book(id: Book.genesis.id, action: .toggle)) {
            $0.sections[id: Book.genesis.id]?.isExpanded = true
            $0.focused = Book.genesis.id
        }
        
        await store.receive(.book(id: Book.genesis.id, action: .load(.success(.mock)))) {
            $0.sections[id: Book.genesis.id]?.chapters = .mock
        }
        
        await store.send(.book(id: Book.genesis.id, action: .openChapter(.mock))) {
            $0.sections[id: Book.genesis.id]?.chapter = .mock
        }
        
        await store.receive(.book(id: Book.genesis.id, action: .loadChapter(.success(.mock)))) {
            $0.sections[id: Book.genesis.id]?.verses = .mock
        }
        
//        await store.send(.book(id: Book.genesis.id, action: .select))
    }
}





































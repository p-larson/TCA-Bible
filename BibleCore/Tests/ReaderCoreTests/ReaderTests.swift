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
        
        await store.send(.menuDirectory(.task))
        
        
        await store.receive(.menuDirectory(.load(.success(.mock)))) {
            $0.menuDirectory.sections = IdentifiedArray(uniqueElements: [Book].mock.map(Section.State.init(book:)))
        }
    }
    
    @MainActor func testNextChapter() async {
        let clock = TestClock()
        
        let store = TestStore(
            initialState: Reader.State(isDirectoryOpen: false)
        ) {
            Reader()
                ._printChanges()
        } withDependencies: {
            $0.continuousClock = clock
        }
        
        // Open menuDirectory
        await store.send(.openDirectory) {
            $0.isDirectoryOpen = true
        }
        
        // Load menuDirectory
        await store.send(.menuDirectory(.task))
        
        // Receive books
        await store.receive(.menuDirectory(.load(.success(.mock)))) {
            $0.menuDirectory.sections = IdentifiedArray(uniqueElements: [Book].mock.map(Section.State.init(book:)))
        }
        
        // Expand book
        await store.send(.menuDirectory(.book(id: Book.genesis.id, action: .toggle))) {
            $0.menuDirectory.sections[id: Book.genesis.id]?.isExpanded = true
            $0.menuDirectory.focused = Book.genesis.id
        }
        
        // Load chapters from book
        await store.receive(.menuDirectory(.book(id: Book.genesis.id, action: .load(.success(.mock))))) {
            $0.menuDirectory.sections[id: Book.genesis.id]?.chapters = .mock
        }
        
        // Select chapter
        await store.send(.menuDirectory(.book(id: Book.genesis.id, action: .openChapter(.mock)))) {
            $0.menuDirectory.sections[id: Book.genesis.id]?.chapter = .mock
        }

        // Load verses from menuDirectory
        await store.receive(.menuDirectory(.book(id: Book.genesis.id, action: .loadChapter(.success(.mock))))) {
            $0.menuDirectory.sections[id: Book.genesis.id]?.verses = .mock
        }
        
        // Select
        await store.send(.menuDirectory(.book(id: Book.genesis.id, action: .select(.genesis, .mock, .mock, nil)))) {
            $0.isDirectoryOpen = false
        }
        
        // Open page
        await store.receive(.page(.open(.genesis, .mock, [.mock], focused: nil))) {
            $0.page = .init(book: .genesis, chapter: .mock, verses: nil, verse: nil)
        }
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.page(.add(.mock))) {
            $0.page.verses = [.mock]
        }
        
        await store.send(.page(.paginateChapter(forward: true)))
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.page(.clear)) {
            $0.page.verses = nil
        }
        
        await store.receive(.page(.paginateBook(forward: true)))
        
        await store.receive(.page(.open(.exodus, .mock, .mock, focused: nil))) {
            $0.page.book = .exodus
            $0.page.chapter = .mock
            $0.page.verses = nil
            $0.page.verse = nil
        }
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.page(.add(.mock))) {
            $0.page.verses = [.mock]
        }
    }
}

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
        
        
        await store.receive(.directory(.load(.success(.mock)))) {
            $0.directory.sections = IdentifiedArray(uniqueElements: [Book].mock.map(Section.State.init(book:)))
        }
    }
    
    @MainActor func testNextChapter() async {
        let store = TestStore(
            initialState: Reader.State(isDirectoryOpen: false),
            reducer: {
                Reader()
            }
        )
        
        // Open directory
        await store.send(.openDirectory) {
            $0.isDirectoryOpen = true
        }
        
        // Load directory
        await store.send(.directory(.task))
        
        // Receive books
        await store.receive(.directory(.load(.success(.mock)))) {
            $0.directory.sections = IdentifiedArray(uniqueElements: [Book].mock.map(Section.State.init(book:)))
        }
        
        // Expand book
        await store.send(.directory(.book(id: Book.genesis.id, action: .toggle))) {
            $0.directory.sections[id: Book.genesis.id]?.isExpanded = true
            $0.directory.focused = Book.genesis.id
        }
        
        // Load chapters from book
        await store.receive(.directory(.book(id: Book.genesis.id, action: .load(.success(.mock))))) {
            $0.directory.sections[id: Book.genesis.id]?.chapters = .mock
        }
        
        // Select chapter
        await store.send(.directory(.book(id: Book.genesis.id, action: .openChapter(.mock)))) {
            $0.directory.sections[id: Book.genesis.id]?.chapter = .mock
        }

        // Load verses from chapter
        await store.receive(.directory(.book(id: Book.genesis.id, action: .loadChapter(.success(.mock))))) {
            $0.directory.sections[id: Book.genesis.id]?.verses = .mock
        }
        
        // Select
        await store.send(.directory(.book(id: Book.genesis.id, action: .select(.genesis, .mock, .mock, .mock)))) {
            $0.isDirectoryOpen = false
        }
        
        // Open page
        await store.receive(.page(.open(.genesis, .mock, .mock, focused: .mock))) {
            $0.page = .init(book: .genesis, chapter: .mock, verses: .mock, verse: .mock)
        }
        
        await store.send(.page(.paginateChapter(forward: true)))
        
        await store.receive(.page(.clear)) {
            $0.page.verses = nil
        }
        
        await store.receive(.page(.paginateBook(forward: true)))
        
        await store.receive(.page(.open(.exodus, .mock, .mock, focused: nil))) {
            $0.page.book = .exodus
            $0.page.chapter = .mock
            $0.page.verses = .mock
            $0.page.verse = nil
        }
    }
}

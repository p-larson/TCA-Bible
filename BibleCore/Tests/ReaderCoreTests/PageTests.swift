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
    
    @MainActor func testTask() async {
        let store = TestStore(
            initialState: Page.State(),
            reducer: {
                Page()._printChanges()
            }
        )
        
        await store.send(.task)

        await store.receive(.open(.genesis, .mock, [.mock], focused: nil), timeout: .seconds(10)) {
            $0.book = .genesis
            $0.chapter = .mock
            $0.verses = [.mock]
        }
    }
    
    @MainActor func testForwardChapter() async {
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        }
        
        let nextChapter = Chapter(id: Chapter.mock.id + 1)
        
        store.dependencies.bible.chapters = { _ in
            [.mock, nextChapter]
        }
        
        await store.send(.paginateChapter(forward: true))
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.open(.genesis, nextChapter, .mock, focused: nil)) {
            $0.book = .genesis
            $0.chapter = nextChapter
            $0.verses = .mock
        }
        
    }
    
    @MainActor func testBackwardChapter() async {
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        }
        
        let lastChapter = Chapter(id: Chapter.mock.id - 1)
        
        store.dependencies.bible.chapters = { _ in
            [lastChapter, .mock]
        }
        
        await store.send(.paginateChapter(forward: false))
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.open(.genesis, lastChapter, .mock, focused: nil)) {
            $0.book = .genesis
            $0.chapter = lastChapter
            $0.verses = .mock
        }
        
    }
    
    @MainActor func testForwardBook() async {
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        }
        
        await store.send(.paginateBook(forward: true))
        
        await store.receive(.open(.exodus, .mock, .mock, focused: nil)) {
            $0.book = .exodus
        }

    }
    
    @MainActor func testBackwardBook() async {
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        }
        
        await store.send(.paginateBook(forward: false))
        
        await store.receive(.open(.leviticus, .mock, .mock, focused: nil)) {
            $0.book = .leviticus
        }
    }
    
    /// Test backward 2x pagination from the second chapter of a Book.
    /// Book 1 Chapter 2 -> Book 1 Chapter 1 -> Book Last Chapter Last
    @MainActor func testBackwardBookPagination() async {
        let chapters = [
            Chapter(id: 1),
            Chapter(id: 2)
        ]
        
        let books = [
            Book.genesis,
            Book.leviticus
        ]
        
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: chapters.last!, verses: .mock)
        ) {
            Page()
        } withDependencies: {
            $0.bible.chapters = { id in
                return chapters
            }
            $0.bible.books = {
                return books
            }
        }
        
        await store.send(.paginateChapter(forward: false))
    
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.open(.genesis, chapters.first!, .mock, focused: nil)) {
            $0.chapter = chapters.first!
            $0.verses = .mock
        }
        
        // New book, should have "different" chapters
        store.dependencies.bible.chapters = { _ in
            return [.mock]
        }
        
        await store.send(.paginateChapter(forward: false))
        
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.paginateBook(forward: false))
        
        await store.receive(.open(.leviticus, .mock, .mock, focused: nil)) {
            $0.book = books.last!
            $0.chapter = .mock
            $0.verses = .mock
        }
    }
}

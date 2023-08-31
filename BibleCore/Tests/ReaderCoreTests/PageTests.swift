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
        let clock = TestClock()
        
        let store = TestStore(
            initialState: Page.State()
        ) {
            Page()._printChanges()
        } withDependencies: {
            $0.defaults = .liveValue
            $0.continuousClock = clock
        }
        
        await store.send(.firstReading)

        await store.receive(.open(.genesis, .mock, [.mock], focused: nil, save: true), timeout: .seconds(10)) {
            $0.book = .genesis
            $0.chapter = .mock
            $0.verses = nil
        }
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
        }
    }
    
    @MainActor func testForwardChapter() async {
        let clock = TestClock()
        
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        } withDependencies: {
            $0.defaults = .liveValue
            $0.continuousClock = clock
        }
        
        let nextChapter = Chapter(id: Chapter.mock.id + 1)
        
        store.dependencies.bible.chapters = { _ in
            [.mock, nextChapter]
        }
        
        await store.send(.paginateChapter(forward: true))
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.open(.genesis, nextChapter, .mock, focused: nil, save: true)) {
            $0.book = .genesis
            $0.chapter = nextChapter
            $0.verses = nil
        }
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
        }
        
    }
    
    @MainActor func testBackwardChapter() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        } withDependencies: {
            $0.defaults = .liveValue
            $0.continuousClock = clock
        }
        
        let lastChapter = Chapter(id: Chapter.mock.id - 1)
        
        store.dependencies.bible.chapters = { _ in
            [lastChapter, .mock]
        }
        
        await store.send(.paginateChapter(forward: false))
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.open(.genesis, lastChapter, .mock, focused: nil, save: true)) {
            $0.book = .genesis
            $0.chapter = lastChapter
            $0.verses = nil
        }
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
        }
        
    }
    
    @MainActor func testForwardBook() async {
        let clock = TestClock()
        
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        } withDependencies: {
            $0.defaults = .liveValue
            $0.continuousClock = clock
        }
        
        await store.send(.paginateBook(forward: true))
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.open(.exodus, .mock, .mock, focused: nil, save: true)) {
            $0.book = .exodus
            $0.verses = nil
        }
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
        }

    }
    
    @MainActor func testBackwardBook() async {
        let clock = TestClock()
        
        let store = TestStore(
            initialState: Page.State(book: .genesis, chapter: .mock, verses: .mock)
        ) {
            Page()
        } withDependencies: {
            $0.defaults = .liveValue
            $0.continuousClock = clock
        }
        
        await store.send(.paginateBook(forward: false))
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.open(.leviticus, .mock, .mock, focused: nil, save: true)) {
            $0.book = .leviticus
            $0.verses = nil
        }
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
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
        
        let clock = TestClock()
        
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
            
            $0.continuousClock = clock
            $0.defaults = .liveValue
        }
        
        await store.send(.paginateChapter(forward: false))
    
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        
        await store.receive(.open(.genesis, chapters.first!, .mock, focused: nil, save: true)) {
            $0.chapter = chapters.first!
            $0.verses = nil
        }
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
        }
        
        // New book, should have "different" chapters
        store.dependencies.bible.chapters = { _ in
            return [.mock]
        }
        
        await store.send(.paginateChapter(forward: false))
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.clear) {
            $0.verses = nil
        }
        
        await store.receive(.paginateBook(forward: false))
        
        await store.receive(.open(.leviticus, .mock, .mock, focused: nil, save: true)) {
            $0.book = books.last!
            $0.chapter = .mock
            $0.verses = nil
        }
        
        await clock.advance(by: .seconds(10))
        
        await store.receive(.add(.mock)) {
            $0.verses = [.mock]
        }
        
    }
}

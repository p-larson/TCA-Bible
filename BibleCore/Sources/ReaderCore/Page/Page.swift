import SwiftUI
import BibleClient
import BibleCore
import ComposableArchitecture

public struct Page: Reducer {
    
    private enum CancelId: Hashable {
        case verses
    }
    
    public struct State: Equatable {
        var book: Book?
        var chapter: Chapter?
        var verses: [Verse]?
        var verse: Verse? = nil
        
        public init(
            book: Book? = nil,
            chapter: Chapter? = nil,
            verses: [Verse]? = nil,
            verse: Verse? = nil
        ) {
            self.book = book
            self.chapter = chapter
            self.verses = verses
            self.verse = verse
        }
        
        var isRedacted: Bool {
            verses == nil
        }
    }
    
    public enum Action: Equatable {
        case task
        case open(Book, Chapter, [Verse], focused: Verse?)
        case jump(Book, Chapter)
        case select(Verse)
        case paginateChapter(forward: Bool)
        case paginateBook(forward: Bool)
        case clear
        case add(Verse)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                switch (state.book == nil, state.chapter == nil) {
                case (true, true):
                    return .run { send in
                        let books = try await self.bible.books()
                        
                        guard let book = books.first else {
                            return
                        }
                        
                        let chapters = try await self.bible.chapters(book.id)
                        
                        guard let chapter = chapters.first else {
                            return
                        }
                        
                        let verses = try await self.bible.verses(book.id, chapter.id)
                        
                        await send(.open(book, chapter, verses, focused: nil))
                    }
                default:
                    return .none
                }
            case .clear:
                state.verses = nil
                return .cancel(id: CancelId.verses)
            case .paginateChapter(forward: true):
                guard let book = state.book, let chapter = state.chapter else {
                    return .none
                }
                return .run { [
                    book = book,
                    chapter = chapter
                ] send in
                    // Clear the screen
                    await send(.clear)
                    
                    let chapters = try await bible.chapters(book.id)
                    
                    if chapters.last != chapter, let index = chapters.firstIndex(of: chapter) {
                        let newChapter = chapters[chapters.index(after: index)]
                        let verses = try await bible.verses(book.id, newChapter.id)
                        
                        await send(.open(book, newChapter, verses, focused: nil))
                        
                    } else {
                        await send(.paginateBook(forward: true))
                    }
                }
            case .paginateBook(forward: true):
                guard let book = state.book else {
                    return .none
                }
                
                return .run { [
                    book = book
                ] send in
                    
                    let books = try await bible.books()
                    
                    var nextBook: Book?
                    
                    if let currentIndex = books.firstIndex(of: book) {
                        switch books[currentIndex].id {
                        case books.last?.id:
                            nextBook = books.first
                        default:
                            nextBook = books[books.index(after: currentIndex)]
                        }
                    }
                    
                    if let nextBook = nextBook {
                        let chapters = try await bible.chapters(nextBook.id)
                        
                        guard let firstChapter = chapters.first else {
                            return
                        }
                        
                        let verses = try await bible.verses(nextBook.id, firstChapter.id)
                        
                        await send(.open(nextBook, firstChapter, verses, focused: nil))
                    }
                }
            case .paginateChapter(forward: false):
                guard let book = state.book, let chapter = state.chapter else {
                    return .none
                }
                return .run { [
                    book = book,
                    chapter = chapter
                ] send in
                    await send(.clear)
                    
                    let chapters = try await bible.chapters(book.id)
                    
                    if chapters.first != chapter, let index = chapters.firstIndex(of: chapter) {
                        let newChapter = chapters[chapters.index(before: index)]
                        let verses = try await bible.verses(book.id, newChapter.id)
                        
                        await send(.open(book, newChapter, verses, focused: nil))
                        
                    } else {
                        await send(.paginateBook(forward: false))
                    }
                }
            case .paginateBook(forward: false):
                guard let book = state.book else {
                    return .none
                }
                
                return .run { [
                    book = book
                ] send in
                    let books = try await bible.books()
                    
                    var nextBook: Book?
                    
                    if let currentIndex = books.firstIndex(of: book) {
                        switch books[currentIndex].id {
                        case books.first?.id:
                            nextBook = books.last
                        default:
                            nextBook = books[books.index(before: currentIndex)]
                        }
                    }
                    
                    if let nextBook = nextBook {
                        let chapters = try await bible.chapters(nextBook.id)
                        
                        guard let lastChapter = chapters.last else {
                            return
                        }
                        
                        let verses = try await bible.verses(nextBook.id, lastChapter.id)
                        
                        await send(.open(nextBook, lastChapter, verses, focused: nil))
                    }
                }
            case .open(let book, let chapter, let verses, let verse):
                state.book = book
                state.chapter = chapter
                state.verse = verse
                state.verses = nil
                
                // Loop through the new verses and animate them into state consecutively
                return .run { [verses = verses] send in
                    for verse in verses {
                        try await clock.sleep(for: .milliseconds(30))
                        await send(.add(verse), animation: .easeOut(duration: 0.3))
                    }
                }
                .cancellable(id: CancelId.verses)
            case .add(let verse):
                if state.verses == nil {
                    state.verses = [verse]
                } else {
                    state.verses?.append(verse)
                }
                return .none
            case .jump(let book, let chapter):
                return .run { send in
                    let verses = try await bible.verses(book.id, chapter.id)
                    
                    await send(.open(book, chapter, verses, focused: nil))
                }
            case .select(let verse):
                state.verse = verse
                return .none
            }
        }
    }
}

import SwiftUI
import BibleClient
import BibleCore
import ComposableArchitecture
import UserDefaultsClient

public struct Page: Reducer {
    
    private enum CancelId: Hashable {
        case verses
        case attemptReload
        case firstReading
    }
    
    public struct State: Equatable, Codable {
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
        case attemptReload
        case firstReading
        case open(Book, Chapter, [Verse], focused: Verse?, save: Bool)
        case jump(Book, Chapter)
        case select(Verse)
        case paginateChapter(forward: Bool)
        case paginateBook(forward: Bool)
        case clear
        case add(Verse)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.defaults) var defaults: UserDefaultsClient
    
    fileprivate let encoder = JSONEncoder()
    fileprivate let decoder = JSONDecoder()
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .attemptReload:
                return .run { send in
                    
                    let data = try? await defaults.get(lastSaveKey)
                    print("data!, ", data == nil)
                    guard
                        let data = data,
                        let save = try? decoder.decode(State.self, from: data),
                        let book = save.book,
                        let chapter = save.chapter,
                        let verses = save.verses
                    else {
                        await send(.firstReading)
                        return
                    }
                    
                    print("loading", save.book?.name.description ?? "-", save.chapter?.id.description ?? "-")
                    
                    await send(.open(book, chapter, verses, focused: save.verse, save: false))
                }
                .cancellable(id: CancelId.attemptReload)
            case .firstReading:
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
                    
                    await send(.open(book, chapter, verses, focused: nil, save: true))
                }
                .cancellable(id: CancelId.firstReading)
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
                        
                        await send(.open(book, newChapter, verses, focused: nil, save: true))
                        
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
                        
                        await send(.open(nextBook, firstChapter, verses, focused: nil, save: true))
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
                        
                        await send(.open(book, newChapter, verses, focused: nil, save: true))
                        
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
                        
                        await send(.open(nextBook, lastChapter, verses, focused: nil, save: true))
                    }
                }
            case .open(let book, let chapter, let verses, let verse, let shouldSave):
                state.book = book
                state.chapter = chapter
                state.verse = verse
                state.verses = nil
                return .concatenate(
                    .cancel(id: CancelId.verses),
                    .cancel(id: CancelId.firstReading),
                    .run { [state = state, verses = verses] send in
                        // Loop through the new verses and animate them into state consecutively
                        for verse in verses {
                            try await clock.sleep(for: .milliseconds(30))
                            await send(.add(verse), animation: .easeOut(duration: 0.3))
                        }
                        
                        // Update recent save
                        if shouldSave {
                            var copy = state
                            
                            copy.verses = verses
                            
                            guard
                                let data = try? encoder.encode(copy)
                            else {
                                return
                            }
                            
                            print("saving", state)
                            try await defaults.set(data, lastSaveKey)
                            let foo = try! await decoder.decode(Self.State.self, from: try! defaults.get(lastSaveKey)!)
                            print("--- save", foo)
                        }
                    }
                    .cancellable(id: CancelId.verses)
                )
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
                    
                    await send(.open(book, chapter, verses, focused: nil, save: false))
                }
            case .select(let verse):
                state.verse = verse
                return .none
            }
        }
    }
}

fileprivate let lastSaveKey: String = "last-save"

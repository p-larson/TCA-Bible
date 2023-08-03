import SwiftUI
import BibleClient
import BibleCore
import ComposableArchitecture

public struct Page: Reducer {
    public struct State: Equatable {
        var book: Book?
        var chapter: Chapter?
        var verses: [Verse]?
    }
    
    public enum Action: Equatable {
        case task
        case open(Book, Chapter, [Verse])
        case paginateChapter(forward: Bool)
        case paginateBook(forward: Bool)
        case clear
    }
    
    @Dependency(\.bible) var bible: BibleClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                guard state.book == nil else {
                    return .none
                }
                
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
                    
                    await send(.open(book, chapter, verses))
                }
            case .clear:
                state.verses = nil
                return .none
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
                        
                        await send(.open(book, newChapter, verses))
                        
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
                        
                        await send(.open(nextBook, firstChapter, verses))
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
                        let newChapter = chapters[chapters.index(after: index)]
                        let verses = try await bible.verses(book.id, newChapter.id)
                        
                        await send(.open(book, newChapter, verses))
                        
                    } else {
                        await send(.paginateBook(forward: true))
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
                        
                        guard let lastChapter = chapters.first else {
                            return
                        }
                        
                        let verses = try await bible.verses(nextBook.id, lastChapter.id)
                        
                        await send(.open(nextBook, lastChapter, verses))
                    }
                }
            case .open(let book, let chapter, let verses):
                state.book = book
                state.chapter = chapter
                state.verses = verses
                return .none
            }
        }
    }
}

struct ContentView: View {
    let store: StoreOf<Page>

    func swipe(store: ViewStoreOf<Page>) -> some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width < 0 {
                    store.send(.paginateChapter(forward: true))
                } else {
                    store.send(.paginateChapter(forward: false))
                }
            }
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                if let verses = viewStore.verses {
                    LazyVStack {
                        ForEach(verses) { content in
                            Text(content.verse)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .task {
                viewStore.send(.task)
            }
            .gesture(swipe(store: viewStore))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: Page.State()) {
            Page()
                ._printChanges()
        })
        .previewDevice("iPhone 14")
    }
}

import BibleCore
import BibleClient
import SwiftUI
import ComposableArchitecture

public struct Section: Reducer {
    public struct State: Equatable, Hashable, Identifiable {
        public var book: Book
        public var chapters: [Chapter] = []
        public var chapter: Chapter? = nil
        public var verses: [Verse]? = nil
        public var isExpanded: Bool = false
        
        public var id: BookID {
            book.id
        }
        
        public init(book: Book) {
            self.book = book
        }
    }
    
    public enum Action: Equatable {
        case toggle
        case load(TaskResult<[Chapter]>)
        case openChapter(Chapter)
        case loadChapter(TaskResult<[Verse]>)
        case select(Book, Chapter, [Verse], Verse)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .toggle:
                state.isExpanded.toggle()
                
                if !state.chapters.isEmpty || !state.isExpanded {
                    return .none
                }
                
                // Load in the chapters assosiated with this book
                return .run { [book = state.book.id] send in
                    await send(.load(
                        TaskResult { try await bible.chapters(book) }
                    ))
                }
            case .openChapter(let chapter):
                state.chapter = chapter
                // Load in the verses assosiated with this chapter
                return .run { [book = state.book.id, chapter = chapter.id] send in
                    await send(.loadChapter(
                        TaskResult { try await bible.verses(book, chapter) }
                    ))
                }
            case .load(.success(let chapters)):
                state.chapters = chapters
                return .none
            case .load(.failure(_)):
                fatalError()
            case .select:
                return .none
            case .loadChapter(.success(let verses)):
                state.verses = verses
                return .none
            case .loadChapter(.failure(_)):
                fatalError()
            }
        }
        
    }
}

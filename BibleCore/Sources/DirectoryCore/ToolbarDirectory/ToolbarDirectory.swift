import BibleCore
import BibleClient
import ComposableArchitecture

@available(macOS 13.0, *)
public struct ToolbarDirectory: Reducer {
    
    public init() { }
    
    public struct State: Equatable {
        var books: IdentifiedArrayOf<Book>?
        var chapters: IdentifiedArrayOf<Chapter>?
        var verses: IdentifiedArrayOf<Verse>?
        
        @BindingState var book: Book? = nil
        @BindingState var chapter: Chapter? = nil
        
        public init(books: IdentifiedArrayOf<Book>? = nil, chapters: IdentifiedArrayOf<Chapter>? = nil, verses: IdentifiedArrayOf<Verse>? = nil, book: Book? = nil, chapter: Chapter? = nil) {
            self.books = books
            self.chapters = chapters
            self.verses = verses
            self.book = book
            self.chapter = chapter
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case loadBooks
        case getBook(TaskResult<[Book]>)
        case getChapters(TaskResult<[Chapter]>)
        case openBook(Book)
        case select(Book, Chapter)
        case binding(_ action: BindingAction<State>)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .loadBooks:
                return .run { send in
                    await send(.getBook(TaskResult(catching: bible.books)))
                }
            case .getBook(.success(let books)):
                state.books = IdentifiedArray(uniqueElements: books)
                
                if state.book == nil, let first = books.first {
                    return .send(.openBook(first))
                }
                
                return .none
            case .getBook(.failure(let error)):
                return .none
            case .openBook(let book):
                state.book = book
                state.chapter = nil
                state.chapters = nil
                
                return .run { send in
                    await send(
                        .getChapters(
                            TaskResult<[Chapter]> {
                                try await bible.chapters(book.id)
                            }
                        )
                    )
                }
            case .getChapters(.success(let chapters)):
                state.chapters = IdentifiedArray(uniqueElements: chapters)
                return .none
            case .getChapters(.failure(let error)):
                return .none
            case .select:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

import SwiftUI
import BibleCore
import BibleClient
import ComposableArchitecture

public struct Directory: ReducerProtocol {
    
    public struct State: Equatable {
        var isDirectoryOpen: Bool
        var books: IdentifiedArrayOf<BookSection.State> = []
        
        public init(
            isDirectoryOpen: Bool,
            books: IdentifiedArrayOf<BookSection.State>
        ) {
            self.isDirectoryOpen = isDirectoryOpen
            self.books = books
        }
    }
    
    public enum Action: Equatable {
        case task
        case load(TaskResult<[Book]>)
        case book(id: UUID, action: BookSection.Action)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    
    public var body: some ReducerProtocolOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.load(TaskResult {
                        try await bible.books()
                    }))
                }
            case .load(.success(let books)):
                state.books = IdentifiedArray(
                    uniqueElements: books.map { book in
                        BookSection.State(book: book)
                    }
                )
                return .none
            case .load(.failure(_)):
                fatalError()
                
            case .book(id: let id, action: .select(let book, let chapter, let verses, let verse)):
                print("child selected", id, book.id, chapter.id, verses.count, verse.id)
                return .none
            default:
                return .none
            }
        }
        .forEach(\.books, action: /Action.book(id:action:)) {
            BookSection()
        }
    }
}

public struct DirectoryView: View {
    let store: StoreOf<Directory>
    
    public init(store: StoreOf<Directory>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                if viewStore.books.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    ForEachStore(
                        store.scope(
                            state: \.books,
                            action: Directory.Action.book(id:action:)
                        ),
                        content: BookSectionView.init(store:)
                    )
                }
            }
            .task {
                viewStore.send(.task)
            }
        }
    }
}

extension Directory.State {
    static let mock = Self(
        isDirectoryOpen: true,
        books: []
    )
}

struct DirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DirectoryView(
                store: Store(initialState: .mock) {
                    Directory()//._printChanges()
                }
            )
        }
        .previewDevice("iPhone 14")
    }
}

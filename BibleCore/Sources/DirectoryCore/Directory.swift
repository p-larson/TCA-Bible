import SwiftUI
import BibleCore
import BibleClient
import ComposableArchitecture

public struct Directory: Reducer {
    
    // Do I really need to declare an explicit public initiallizer?
    public init() {}
    
    public struct State: Equatable {
        public var isDirectoryOpen: Bool
        public var sections: IdentifiedArrayOf<Section.State> = []
        
        public init(
            isDirectoryOpen: Bool,
            books: IdentifiedArrayOf<Section.State>
        ) {
            self.isDirectoryOpen = isDirectoryOpen
            self.sections = books
        }
    }
    
    public enum Action: Equatable {
        case task
        case load(TaskResult<[Book]>)
        case book(id: BookID, action: Section.Action)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    
    public var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.load(TaskResult {
                        try await bible.books()
                    }))
                }
            case .load(.success(let books)):
                state.sections = IdentifiedArray(
                    uniqueElements: books.map(Section.State.init(book:))
                )
                
                return .none
            case .load(.failure(_)):
                fatalError()
            case .book(id: let id, action: .select(let book, _, _, _)):
                print(id, #file, book.name)
                return .none
            default:
                return .none
            }
        }
        .forEach(\.sections, action: /Action.book(id:action:)) {
            Section()
        }
    }
}

public struct DirectoryView: View {
    let store: StoreOf<Directory>
    
    public init(store: StoreOf<Directory>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.sections) { viewStore in
            ScrollView {
                if viewStore.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    ForEachStore(
                        store.scope(
                            state: \.sections,
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
                    Directory()
                }
            )
        }
        .previewDevice("iPhone 14")
    }
}

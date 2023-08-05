import BibleClient
import BibleCore
import CasePaths
import SwiftUI
import ComposableArchitecture
import DirectoryCore

public struct Reader: Reducer {
    public init() {
        // :)
    }
    
    public struct State: Equatable {
        var page = Page.State()
        var directory: Directory.State = Directory.State(
            isDirectoryOpen: true,
            books: []
        )
        
        @BindingState public var isDirectoryOpen: Bool = false
        
        public init(
            isDirectoryOpen: Bool = false
        ) {
            self.isDirectoryOpen = isDirectoryOpen
        }
        
        var contentName: String? {
            guard let book = page.book else {
                return nil
            }

            guard let chapter = page.chapter else {
                return book.name
            }

            return book.name + " " + chapter.id.description
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(_ action: BindingAction<State>)
        case openDirectory
        case page(Page.Action)
        case directory(Directory.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.directory, action: /Action.directory) {
            Directory()
        }
        Scope(state: \.page, action: /Action.page) {
            Page()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .openDirectory:
                state.isDirectoryOpen = true
                return .none
            case .directory(.book(id: _, action: .select(let book, let chapter, let verses, let verse))):
                print("opening \(book.name)")
                
                state.isDirectoryOpen = false
                return .send(.page(.open(book, chapter, verses, focused: verse)))
            case .directory:
                return .none
            case .page:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

public struct ReaderView: View {
    let store: StoreOf<Reader>
    
    public init(store: StoreOf<Reader>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Button {
                        viewStore.send(.openDirectory)
                    } label: {
                        if let book = viewStore.contentName {
                            Text(book)
                        } else {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .buttonStyle(.bordered)

                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                ScrollView {
                    ContentView(
                        store: store.scope(
                            state: \.page,
                            action: Reader.Action.page
                        )
                    )
                }
            }
            .sheet(isPresented: viewStore.$isDirectoryOpen) {
                NavigationStack {
                    DirectoryView(
                        store: store.scope(
                            state: \.directory,
                            action: Reader.Action.directory
                        )
                    )
                    .navigationTitle("Books")
                }
            }
        }
    }
}

extension Reader.State {
    static let mock = Reader.State(
        isDirectoryOpen: false
    )
}

struct BookReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ReaderView(
            store: Store(
                initialState: .mock
            ) {
                Reader()
            }
        )
        .previewDevice("iPhone 14")
    }
}

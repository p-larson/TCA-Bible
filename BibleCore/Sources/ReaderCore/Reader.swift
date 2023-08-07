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
        var menuDirectory: MenuDirectory.State = MenuDirectory.State(
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
        case menuDirectory(MenuDirectory.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.menuDirectory, action: /Action.menuDirectory) {
            MenuDirectory()
        }
        Scope(state: \.page, action: /Action.page) {
            Page()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .openDirectory:
                state.isDirectoryOpen = true
                return .none
            case .menuDirectory(.book(id: _, action: .select(let book, let chapter, let verses, let verse))):
                print("opening \(book.name)")
                
                state.isDirectoryOpen = false
                return .send(.page(.open(book, chapter, verses, focused: verse)))
            case .menuDirectory:
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
                #if os(iOS)
                    HStack {
                        Button {
                            viewStore.send(.openDirectory)
                        } label: {
                            if let book = viewStore.contentName {
                                Text(book)
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.mini)
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                #endif
                Spacer()
                ScrollView {
                    PageView(
                        store: store.scope(
                            state: \.page,
                            action: Reader.Action.page
                        )
                    )
                }
            }
            #if os(macOS)
                .toolbar {
                    ToolbarItem {
                        Text("Hello")
                    }
                }
                .aspectRatio(8.5/11, contentMode: .fill)
                .frame(minWidth: 425, minHeight: 550, alignment: .topLeading)
                .presentedWindowToolbarStyle(.unifiedCompact(showsTitle: true))
            #endif
            .popover(isPresented: viewStore.$isDirectoryOpen) {
                NavigationStack {
                    MenuDirectoryView(
                        store: store.scope(
                            state: \.menuDirectory,
                            action: Reader.Action.menuDirectory
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
        .previewDisplayName("Mobile")
        .previewDevice("iPhone 14")
        
        ReaderView(
            store: Store(initialState: .mock) {
                Reader()
            }
        )
        .previewLayout(.sizeThatFits)
        .previewDevice("Mac")
        .previewDisplayName("Desktop")
    }
}

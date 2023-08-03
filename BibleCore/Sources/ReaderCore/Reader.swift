import BibleClient
import BibleCore
import CasePaths
import SwiftUI
import ComposableArchitecture
import DirectoryCore

public struct Reader: Reducer {
    public struct State: Equatable {
        var content = Page.State()
        var directory: Directory.State = Directory.State(
            isDirectoryOpen: true,
            books: []
        )
        
        @BindingState public var isDirectoryOpen: Bool = false
        
        init(
            isDirectoryOpen: Bool
        ) {
            self.isDirectoryOpen = isDirectoryOpen
        }
        
        var contentName: String? {
            guard let book = content.book else {
                return nil
            }

            guard let chapter = content.chapter else {
                return book.name
            }

            return book.name + " " + chapter.id.description
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(_ action: BindingAction<State>)
        case bookmark
        case openBible
        case openDirectory
        case content(Page.Action)
        case directory(Directory.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.directory, action: /Action.directory) {
            Directory()
        }
        Scope(state: \.content, action: /Action.content) {
            Page()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .openDirectory:
                state.isDirectoryOpen = true
                return .none
            case .directory(.book(id: _, action: .select(let book, let chapter, let verses, let verse))):
                print("selected", book.name, chapter.id, verses.count, verse.verseId, book.name)
                
                return .none
            case .bookmark:
                // Find the last reading
                // TODO:
                return .none
            default:
                return .none
            }
        }
    }
}

struct BookReaderView: View {
    let store: StoreOf<Reader>

    var body: some View {
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
                            state: \.content,
                            action: Reader.Action.content
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
            .task {
                store.send(.bookmark)
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
        BookReaderView(
            store: Store(
                initialState: .mock
            ) {
                Reader()
            }
        )
        .previewDevice("iPhone 14")
    }
}

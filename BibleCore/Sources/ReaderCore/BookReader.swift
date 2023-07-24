import BibleClient
import BibleCore
import CasePaths
import SwiftUI
import ComposableArchitecture
import DirectoryCore

public struct BookReader: ReducerProtocol {
    public struct State: Equatable {
        var content = Content.State()
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
        case content(Content.Action)
        case directory(Directory.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.directory, action: /Action.directory) {
            Directory()
        }
        Scope(state: \.content, action: /Action.content) {
            Content()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .openDirectory:
                state.isDirectoryOpen = true
                return .none
            case .directory(.book(id: _, action: .select(let book, let chapter, let verses, let verse))):
                print("selected", book.id, chapter.id, verses.count, verse.id, book.name)
                
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
    let store: StoreOf<BookReader>

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

                }
                Spacer()
                ScrollView {
                    ContentView(
                        store: store.scope(
                            state: \.content,
                            action: BookReader.Action.content
                        )
                    )
                }
            }
            .sheet(isPresented: viewStore.$isDirectoryOpen) {
                NavigationStack {
                    DirectoryView(
                        store: store.scope(
                            state: \.directory,
                            action: BookReader.Action.directory
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

extension BookReader.State {
    static let mock = BookReader.State(
        isDirectoryOpen: false
    )
}

struct BookReaderView_Previews: PreviewProvider {
    static var previews: some View {
        BookReaderView(
            store: Store(
                initialState: .mock
            ) {
                BookReader()
            }
        )
        .previewDevice("iPhone 14")
    }
}

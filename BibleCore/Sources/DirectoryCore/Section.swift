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

fileprivate struct IndexView: View {
    let index: Int
    
    var body: some View {
        Text(String(describing: index))
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity, alignment: .center)
            .aspectRatio(1, contentMode: .fit)
            .background {
                Color.white.cornerRadius(4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color.black.opacity(1/10))
            }
            .contentShape(RoundedRectangle(cornerRadius: 4))
            .foregroundColor(.black)
    }
}

public struct BookSectionView: View {
    let store: StoreOf<Section>
    @ObservedObject var viewStore: ViewStoreOf<Section>
    
    init(store: StoreOf<Section>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    public var body: some View {
        VStack {
            HStack {
                Text(viewStore.book.name)
                Spacer()
                Image(systemName: "chevron.down")
                    .imageScale(.small)
                    .rotationEffect(.degrees(viewStore.isExpanded ? 180 : 0))
            }
            .frame(height: 40, alignment: .bottom)
            
            if viewStore.isExpanded {
                if viewStore.chapters.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 5)) {
                        ForEach(viewStore.chapters) { chapter in
                            NavigationLink(value: chapter) {
                                IndexView(index: chapter.id as Int)
                            }
                        }
                    }
                    .navigationDestination(for: Chapter.self) { chapter in
                        ScrollView {
                            if let verses = viewStore.verses, !verses.isEmpty {
                                LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 5)) {
                                    ForEach(verses) { verse in
                                        Button {
                                            
                                            viewStore.send(
                                                .select(
                                                    viewStore.book,
                                                    chapter,
                                                    viewStore.verses!,
                                                    verse
                                                )
                                            )
                                        } label: {
                                            IndexView(index: verse.verseId)
                                        }
                                        
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                        }
                        .task {
                            viewStore.send(.openChapter(chapter))
                        }
                        .navigationTitle("Select Verse")
                    }
                }
            }
        }
        .padding(viewStore.isExpanded ? [.horizontal, .bottom] : [.horizontal])
        .onTapGesture {
            viewStore.send(.toggle, animation: .easeOut(duration: 0.3))
        }
        .background {
            if viewStore.isExpanded {
                Color.accentColor.opacity(15 / 100)
            }
        }
        .id(viewStore.book.id)
    }
}

public extension Section.State {
    static let mock = Self(
        book: .genesis
    )
}

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollView {
                BookSectionView(store: StoreOf<Section>(
                    initialState: .mock,
                    reducer: {
                        Section()
                    })
                )
            }
        }
        .previewDevice("iPhone 14")
    }
}

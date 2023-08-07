import ComposableArchitecture
import BibleCore
import SwiftUI

@available(macOS 13.0, *)
public struct ToolbarDirectoryView: View {
    let store: StoreOf<ToolbarDirectory>
    
    public init(store: StoreOf<ToolbarDirectory>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                if let books = viewStore.books {
                    Picker(selection: viewStore.$book) {
                        ForEach(books) { book in
                            Text(book.name)
                                // This is beyond the silliest part of SwiftUI.
                                // BindingState<Optional<Book>> requires tag to SwiftUI.View#tag to be Optional<Book>
                                // otherwise, Optional<Book> equate to Book will always fail.
                                .tag(Book?.some(book))
                        }
                    } label: {
                        Text("Book")
                    }
                    .onChange(of: viewStore.book) { newValue in
                        guard let book = newValue else { return }
                        viewStore.send(.openBook(book))
                    }
                    
                    if let book = viewStore.book, let chapters = viewStore.chapters {
                        Picker(selection: viewStore.$chapter) {
                            ForEach(chapters) { chapter in
                                Text(chapter.id.description)
                                    .tag(Chapter?.some(chapter))
                            }
                        } label: {
                            Text("Chapter")
                        }
                        .onChange(of: viewStore.chapter) { newValue in
                            guard let chapter = newValue else { return }

                            viewStore.send(.select(book, chapter))
                        }

                    } else {
                        ProgressView()
                    }
                    
                } else {
                    ProgressView()
                }
            }
            .progressViewStyle(.circular)
            .pickerStyle(.menu)
            .controlSize(.small)
            .task { viewStore.send(.loadBooks) }
        }
    }
}

public struct ToolbarDirectoryView_Previews: PreviewProvider {
    public static var previews: some View {
        ToolbarDirectoryView(store: Store(initialState: ToolbarDirectory.State()) {
            ToolbarDirectory()
                 ._printChanges() // Doesn't work with Mac previews... :(
        })
        .padding()
        .previewDevice("Mac")
        .previewDisplayName("Desktop")
        .previewLayout(.fixed(width: 200, height: 100))
    }
}

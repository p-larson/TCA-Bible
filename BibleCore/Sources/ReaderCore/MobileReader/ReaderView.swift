import ComposableArchitecture
import DirectoryCore
import SwiftUI

public struct ReaderView: View {
    let store: StoreOf<Reader>
    
    public init(store: StoreOf<Reader>) {
        self.store = store
    }
    
    func arrows(_ viewStore: ViewStoreOf<Reader>) -> some View {
        HStack {
            Button {
                viewStore.send(.page(.paginateChapter(forward: false)))
            } label: {
                Image(systemName: "arrow.left")
            }
            Spacer()
            Button {
                viewStore.send(.page(.paginateChapter(forward: true)))
            } label: {
                Image(systemName: "arrow.right")
            }
        }
        .shadow(radius: 8)
        .buttonStyle(.borderedProminent)
        .padding()
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
                                    .controlSize(.mini)
                            }
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                    .padding(.horizontal)
                PageView(
                    store: store.scope(
                        state: \.page,
                        action: Reader.Action.page
                    )
                )
            }
            .overlay(
                HStack {
                    Button {
                        viewStore.send(.page(.paginateChapter(forward: false)))
                    } label: {
                        Image(systemName: "arrow.left")
                    }
                    Spacer()
                    Button {
                        viewStore.send(.page(.paginateChapter(forward: true)))
                    } label: {
                        Image(systemName: "arrow.right")
                    }
                }
                    .shadow(radius: 8)
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            )
            .popover(isPresented: viewStore.$isDirectoryOpen) {
                NavigationStack {
                    DirectoryView(
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
    }
}

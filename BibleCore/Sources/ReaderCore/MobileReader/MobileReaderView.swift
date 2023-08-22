import ComposableArchitecture
import DirectoryCore
import SwiftUI

public struct MobileReaderView: View {
    let store: StoreOf<MobileReader>
    
    public init(store: StoreOf<MobileReader>) {
        self.store = store
    }
    
    func arrows(_ viewStore: ViewStoreOf<MobileReader>) -> some View {
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
                        action: MobileReader.Action.page
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
                    MenuDirectoryView(
                        store: store.scope(
                            state: \.menuDirectory,
                            action: MobileReader.Action.menuDirectory
                        )
                    )
                    .navigationTitle("Books")
                }
            }
        }
    }
}

extension MobileReader.State {
    static let mock = MobileReader.State(
        isDirectoryOpen: false
    )
}

struct BookReaderView_Previews: PreviewProvider {
    static var previews: some View {
        MobileReaderView(
            store: Store(
                initialState: .mock
            ) {
                MobileReader()
            }
        )
        .previewDisplayName("Mobile")
        .previewDevice("iPhone 14")
    }
}

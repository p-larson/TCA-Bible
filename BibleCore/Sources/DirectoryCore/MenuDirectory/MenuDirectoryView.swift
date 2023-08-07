import ComposableArchitecture
import SwiftUI

@available(iOS 16.0, *)
public struct MenuDirectoryView: View {
    
    let store: StoreOf<MenuDirectory>
    
    public init(store: StoreOf<MenuDirectory>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    ScrollView {
                        if viewStore.sections.isEmpty {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            ScrollViewReader { reader in
                                ForEachStore(
                                    store.scope(
                                        state: \.sections,
                                        action: MenuDirectory.Action.book(id:action:)
                                    ),
                                    content: SectionView.init(store:)
                                )
                                .onChange(of: viewStore.focused) { newValue in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        reader.scrollTo(newValue, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                    
                    Picker(selection: viewStore.$sorted) {
                        ForEach(MenuDirectory.SortFilter.allCases, id: \.self) {
                            Text(String(describing: $0).capitalized)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
            }
            .task {
                viewStore.send(.task)
            }
        }
    }
}

extension MenuDirectory.State {
    static let mock = Self(
        isDirectoryOpen: true,
        books: []
    )
}

struct MenuDirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        MenuDirectoryView(
            store: Store(initialState: .mock) {
                MenuDirectory()
                    ._printChanges()
            }
        )
        .previewDisplayName("Mobile")
        .previewDevice("iPhone 14")
    }
}

import ComposableArchitecture
import ReaderCore
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppReducer>
    
    @ObservedObject var viewStore: ViewStoreOf<AppReducer>
    
    init(store: StoreOf<AppReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: AppReducer.Action.path)
        ) {
            WithViewStore(store, observe: \.tab) { viewStore in
                TabView(selection: viewStore.binding(send: AppReducer.Action.tabSelected)) {
                    ReaderView(
                        store: store.scope(state: \.reader, action: AppReducer.Action.reader)
                    )
                    .tabItem {
                        Label("Read", systemImage: "book")
                    }
                    
                    Color.white
                        .tabItem {
                            Label("Learn", systemImage: "brain")
                        }
                }
            }
        } destination: { initialState in
            switch initialState {
            case .empty:
                Text("hello")
                    .navigationBarBackButtonHidden(true)
            case .reader:
                CaseLet(
                    /AppReducer.Path.State.reader,
                     action: AppReducer.Path.Action.reader,
                     then: ReaderView.init(store:)
                )
            }
        }

    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(initialState: AppReducer.State(), reducer: {
                AppReducer()
                    ._printChanges()
            })
        )
    }
}

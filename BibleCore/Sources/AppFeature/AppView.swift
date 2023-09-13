import ComposableArchitecture
import Classroom
import ReaderCore
import SwiftUI

public struct AppView: View {
    let store: StoreOf<AppReducer>
    
    @ObservedObject var viewStore: ViewStoreOf<AppReducer>
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    public var body: some View {
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
            case .classroom:
                CaseLet(
                    /AppReducer.Path.State.classroom,
                     action: AppReducer.Path.Action.classroom,
                     then: ClassroomView.init(store:)
                )
                .navigationBarBackButtonHidden(true)
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

import SwiftUI
import ComposableArchitecture
import ReaderCore

// Eventually going to have a tabular navigation,
// going to need this AppView.
// for now it's just a wrapper for our Reader and AppDelegate.

public struct AppView: View {
    let store: StoreOf<AppReducer>
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }
    
    public var body: some View {
        ReaderView(
            store: store.scope(state: \.reader, action: AppReducer.Action.reader(action:))
        )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppReducer.State(
                    reader: Reader.State(),
                    appDelegate: AppDelegateReducer.State()
                ), reducer: {
                    AppReducer()
                }
            )
        )
    }
}

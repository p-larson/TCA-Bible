import ComposableArchitecture
import UIKit

final public class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppReducer.State(
            appDelegate: AppDelegateReducer.State()
        )
    ) {
        AppReducer()
    }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        store.send(.appDelegate(.didFinishOpening))
        return true
    }
}

public struct AppDelegateReducer: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        case didFinishOpening
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didFinishOpening:
                return .none
            }
        }
    }
}

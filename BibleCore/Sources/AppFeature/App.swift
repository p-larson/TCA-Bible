import ReaderCore
import ComposableArchitecture

public struct AppReducer: Reducer {
    public init() {}
    
    public struct State: Equatable {
        public var reader: Reader.State
        public var appDelegate: AppDelegateReducer.State
        
        public init(reader: Reader.State, appDelegate: AppDelegateReducer.State) {
            self.reader = reader
            self.appDelegate = appDelegate
        }
    }
    
    public enum Action: Equatable {
        case appDelegate(action: AppDelegateReducer.Action)
        case reader(action: Reader.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.reader, action: /Action.reader(action:)) {
            Reader()
        }
        Scope(state: \.appDelegate, action: /Action.appDelegate(action:)) {
            AppDelegateReducer()
        }
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                return .run { send in
                    await send(.reader(action: Reader.Action.page(.attemptReload)))
                }
            default:
                return .none
            }
        }
        
    }
}

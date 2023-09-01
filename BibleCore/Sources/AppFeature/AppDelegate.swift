import ComposableArchitecture

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

import ComposableArchitecture

public struct AppDelegateReducer: Reducer {
    public init() {}
    
    public struct State: Equatable {
        var foo: Int = 0
        
        public init() {
            
        }
    }
    
    public enum Action: Equatable {
        case didFinishLaunching
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
    
    
}

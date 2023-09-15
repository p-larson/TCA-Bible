import ComposableArchitecture
import ReaderCore
import Classroom

public struct AppReducer: Reducer {
    
    public struct Path: Reducer {
        public init() {}
        
        
        public enum State: Equatable {
            case classroom(Classroom.State = .init())
        }
        
        public enum Action: Equatable {
            case classroom(Classroom.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: /State.classroom, action: /Action.classroom) {
                Classroom()
            }
            Reduce { state, action in .none }
        }
    }
    
    public init() { }
    
    public struct State: Equatable {
        var appDelegate = AppDelegateReducer.State()
        var path = StackState<Path.State>()
        var reader = Reader.State()
        var tab = Tab.read
        
        public enum Tab: Equatable {
            case learn
            case read
        }
        
        public init(
            appDelegate: AppDelegateReducer.State = AppDelegateReducer.State(),
            path: StackState<Path.State> = StackState<Path.State>(),
            reader: Reader.State = Reader.State(),
            tab: Tab = .read
        ) {
            self.appDelegate = appDelegate
            self.path = path
            self.reader = reader
            self.tab = tab
        }
    }
    
    public enum Action: Equatable {
        case appDelegate(AppDelegateReducer.Action)
        case reader(Reader.Action)
        case path(StackAction<Path.State, Path.Action>)
        case popTo(id: StackElementID)
        case popToRoot
        case tabSelected(State.Tab)
    }
    
    var primary: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .popTo(let id):
                return .none
            case .popToRoot:
                return .none
            case .tabSelected(let tab):
                
                if tab == .read {
                    state.path.append(.classroom())
                }
                
                return .none
            default:
                return .none
            }
        }
    }
    
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: /Action.appDelegate) {
            AppDelegateReducer()
        }
        Scope(state: \.reader, action: /Action.reader) {
            Reader()
        }
        primary
            .forEach(\.path, action: /Action.path) {
                Path()
            }
    }
}

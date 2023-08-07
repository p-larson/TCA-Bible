import DirectoryCore
import ComposableArchitecture

public struct DesktopReader: Reducer {
    public init() { }
    
    public struct State: Equatable {
        var toolbarDirectory: ToolbarDirectory.State
        var page: Page.State
        
        public init(toolbarDirectory: ToolbarDirectory.State = .init(), page: Page.State = .init()) {
            self.toolbarDirectory = toolbarDirectory
            self.page = page
        }
    }
    
    public enum Action: Equatable {
        case toolbarDirectory(ToolbarDirectory.Action)
        case page(Page.Action)
    }
    
    public  var body: some ReducerOf<Self> {
        Scope(state: \.toolbarDirectory, action: /Action.toolbarDirectory) {
            ToolbarDirectory()
        }
        Scope(state: \.page, action: /Action.page) {
            Page()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .toolbarDirectory(.select(let book, let chapter)):
                return .send(.page(.jump(book, chapter)))
            default:
                return .none
            }
        }
    }
}

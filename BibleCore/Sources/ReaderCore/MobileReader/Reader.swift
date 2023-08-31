import BibleClient
import BibleCore
import CasePaths
import SwiftUI
import ComposableArchitecture
import DirectoryCore

public struct Reader: Reducer {
    public init() {
        // :)
    }
    
    public struct State: Equatable {
        var page = Page.State()
        var menuDirectory: MenuDirectory.State = MenuDirectory.State(
            isDirectoryOpen: true,
            books: []
        )
        
        @BindingState public var isDirectoryOpen: Bool = false
        
        public init(
            isDirectoryOpen: Bool = false
        ) {
            self.isDirectoryOpen = isDirectoryOpen
        }
        
        var contentName: String? {
            guard let book = page.book else {
                return nil
            }

            guard let chapter = page.chapter else {
                return book.name
            }

            return book.name + " " + chapter.id.description
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(_ action: BindingAction<State>)
        case openDirectory
        case page(Page.Action)
        case menuDirectory(MenuDirectory.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.menuDirectory, action: /Action.menuDirectory) {
            MenuDirectory()
        }
        Scope(state: \.page, action: /Action.page) {
            Page()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .openDirectory:
                state.isDirectoryOpen = true
                return .none
            case .menuDirectory(.book(id: _, action: .select(let book, let chapter, let verses, let verse))):
                state.isDirectoryOpen = false
                return .send(.page(.open(book, chapter, verses, focused: verse, save: true)))
            case .menuDirectory:
                return .none
            case .page:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

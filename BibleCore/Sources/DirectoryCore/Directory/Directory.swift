import SwiftUI
import BibleCore
import BibleClient
import ComposableArchitecture

public struct Directory: Reducer {
    
    // Do I really need to declare an explicit public initiallizer?
    public init() {}
    
    public enum SortFilter: CaseIterable, Codable {
        case traditional
        case alphabetical
    }
    
    public struct State: Equatable, Codable {
        public var isDirectoryOpen: Bool
        public var sections: IdentifiedArrayOf<Section.State> = []
        public var focused: Book.ID? = nil
        @BindingState public var sorted: SortFilter = .traditional
        
        public init(
            isDirectoryOpen: Bool,
            books: IdentifiedArrayOf<Section.State>
        ) {
            self.isDirectoryOpen = isDirectoryOpen
            self.sections = books
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case task
        case load(TaskResult<[Book]>)
        case book(id: BookID, action: Section.Action)
        case binding(_ action: BindingAction<State>)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.load(TaskResult {
                        try await bible.books()
                    }))
                }
            case .load(.success(let books)):
                state.sections = IdentifiedArray(
                    uniqueElements: books.map(Section.State.init(book:))
                )
                
                return .none
            case .load(.failure(_)):
                fatalError()
            case .book(id: let id, action: .toggle):
                // Close all other sections that are opened that aren't `id`
                for section in state.sections where section.id != id && section.isExpanded {
                    state.sections[id: section.id]?.isExpanded.toggle()
                }
                
                state.focused = state.sections[id:id]?.isExpanded ?? false ? id : nil
                
                return .none
            case .binding(.set(\.$sorted, .traditional)):
                state.sections.sort { s1, s2 in
                    s1.id < s2.id
                }
                return .none
            case .binding(.set(\.$sorted, .alphabetical)):
                state.sections.sort { s1, s2 in
                    s1.book.name < s2.book.name
                }
                return .none
            case .binding:
                return .none
            case .book:
                return .none
            }
        }
        .forEach(\.sections, action: /Action.book(id:action:)) {
            Section()
        }
    }
}

import ComposableArchitecture
import DirectoryCore
import Foundation
import UserDefaultsClient

public struct Classroom: Reducer {
    public init () {}
    
    public struct State: Equatable, Codable {
        var lessons: IdentifiedArrayOf<Lesson.State> = []
        var selected: Lesson.State.ID? = nil
        var directory: Directory.State? = nil
        
        @BindingState var isDirectoryOpen = false
        
        public init(lessons: IdentifiedArrayOf<Lesson.State> = [], selected: Lesson.State.ID? = nil, directory: Directory.State? = nil, isDirectoryOpen: Bool = false) {
            self.lessons = lessons
            self.selected = selected
            self.directory = directory
            self.isDirectoryOpen = isDirectoryOpen
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case task
        case lesson(id: UUID, action: Lesson.Action)
        case select(id: UUID)
        case openDirectory
        case directory(Directory.Action)
        case binding(_ action: BindingAction<State>)
    }
    
    @Dependency(\.defaults) var defaults: UserDefaultsClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
                return .none
            case .select(id: let id):
                state.selected = id
                return .none
            case .lesson:
                return .none
            case .openDirectory:
                state.isDirectoryOpen = true
                state.directory = Directory.State(
                    isDirectoryOpen: true, // TODO: refactor
                    books: []
                )
                return .none
            case .directory(.book(id: _, action: .select(_, _, let verses, _))):
                state.isDirectoryOpen = false
                
                var lesson: Lesson.State? = state.lessons.first { state in
                    state.verses.elementsEqual(verses)
                }
                
                if let lesson = lesson {
                    state.selected = lesson.id
                } else {
                    lesson = Lesson.State(verses: verses)
                    state.lessons.append(lesson!)
                    state.selected = lesson!.id
                }
                
                return .none
            case .directory:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.directory, action: /Action.directory) {
            Directory()
        }
        .forEach(\.lessons, action: /Action.lesson) {
            Lesson()
        }
    }
}

import ComposableArchitecture
import Foundation
import UserDefaultsClient

struct Classroom: Reducer {
    
    struct State: Equatable, Codable {
        var lessons: IdentifiedArrayOf<Lesson.State> = []
        var selected: Lesson.State.ID? = nil
    }
    
    enum Action: Equatable {
        case task
        case lesson(Lesson.Action)
        case select(id: UUID)
    }
    
    @Dependency(\.defaults) var defaults: UserDefaultsClient
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task
                return .run {
                    defaults.get
                }
            case .select(id: let id):
                state.selected = id
                return .none
            case .lesson:
                return .none
            }
        }
    }
}

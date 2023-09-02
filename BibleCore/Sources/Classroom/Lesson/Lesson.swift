import BibleCore
import ComposableArchitecture
import Foundation

struct Lesson: Reducer {
    struct State: Identifiable, Equatable, Codable {
        var verses: [Verse]
        var exercise: Exercise.State?
        var id: UUID
    }
    
    enum Action: Equatable {
        case excercise(Exercise.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        .ifLet(\.exercise, action: /Action.excercise) {
            Exercise()
        }
    }
}

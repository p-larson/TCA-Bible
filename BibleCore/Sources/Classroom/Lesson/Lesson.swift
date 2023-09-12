import BibleCore
import ComposableArchitecture
import Foundation

struct Lesson: Reducer {
    struct State: Identifiable, Equatable, Codable, Hashable {
        var verses: [Verse]
        var exercise: Exercise.State? = nil
        var grade: Grade.State = .disabled
        var id: UUID = UUID()
        
        public init(
            verses: [Verse],
            exercise: Exercise.State? = nil,
            grade: Grade.State = .disabled,
            id: UUID = UUID()
        ) {
            self.verses = verses
            self.exercise = exercise
            self.grade = grade
            self.id = id
        }
    }
    
    enum Action: Equatable {
        case prepare
        case excercise(Exercise.Action)
        case grade(Grade.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.grade, action: /Action.grade) {
            Grade()
        }
        Reduce { state, action in
            switch action {
            case .prepare:
                
                state.exercise = .buildByWord(BuildByWord.State.init(verses: .mock))
                
                return .none
            case .grade(.next):
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.exercise, action: /Action.excercise) {
            Exercise()
        }
    }
}

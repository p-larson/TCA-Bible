import BibleCore
import ComposableArchitecture
import Foundation

public struct Lesson: Reducer {
    public init () {} 
    
    public struct State: Identifiable, Equatable, Codable, Hashable {
        var verses: [Verse]
        var exercise: Exercise.State? = nil
        var grade: Grade.State = .disabled
        var score: Double = 0
        
        public var id: UUID = UUID()
        
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
    
    public enum Action: Equatable {
        case prepare
        case load(Exercise.State)
        case excercise(Exercise.Action)
        case grade(Grade.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.grade, action: /Action.grade) {
            Grade()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .prepare:
                return .run { [verses = state.verses] send in
                    
                    try await clock.sleep(for: .seconds(1))
                    
                    await send(.load(.buildByWord(BuildByWord.State.init(verses: verses))), animation: .easeIn(duration: 0.3))
                }
            case .load(let exercise):
                
                state.score = .random(in: 0 ... 1)
                state.exercise = exercise
                
                return .none
            case .excercise(.buildByWord(BuildByWord.Action.guess)), .excercise(.buildByWord(.remove)):
                if case .buildByWord(let model) = state.exercise {
                    if model.answer.isEmpty {
                        state.grade = Grade.State.disabled
                    } else {
                        state.grade = Grade.State.ready
                    }
                }
                return .none
            case .grade(.didPressButton):
                // Test if we've actually completed the exercise
                
                switch state.grade {
                case .ready:
                    if state.exercise?.isCorrect ?? false {
                        state.grade = .correct
                    }
                    return .none
                case .correct:
                    // Move to the next exercise.
                    state.exercise = nil
                    state.grade = .disabled
                    
                    return .send(.prepare)
                default:
                    break
                }
                
                
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

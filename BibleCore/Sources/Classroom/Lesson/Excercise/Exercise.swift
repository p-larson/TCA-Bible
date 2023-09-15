import BibleCore
import ComposableArchitecture

public struct Exercise: Reducer {
    public init () {}
    
    public enum State: Equatable, Codable, Hashable, ExerciseProtocol {
        var isCorrect: Bool {
            switch self {
            case .buildByLetter(let state):
                return state.isCorrect
            case .buildByWord(let state):
                return state.isCorrect
            }
        }
        
        var score: Int {
            switch self {
            case .buildByLetter(let state):
                return state.score
            case .buildByWord(let state):
                return state.score
            }
            
        }
        
        case buildByWord(BuildByWord.State)
        case buildByLetter(BuildByLetter.State)
    }
    
    public enum Action: Equatable {
        case buildByWord(BuildByWord.Action)
        case buildByLetter(BuildByLetter.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: /State.buildByWord, action: /Action.buildByWord) {
            BuildByWord()
        }
        Scope(state: /State.buildByLetter, action: /Action.buildByLetter) {
            BuildByLetter()
        }
    }
}

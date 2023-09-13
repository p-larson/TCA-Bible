import BibleCore
import ComposableArchitecture

struct Exercise: Reducer {
    enum State: Equatable, Codable, Hashable, ExerciseProtocol {
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
    
    enum Action: Equatable {
        case buildByWord(BuildByWord.Action)
        case buildByLetter(BuildByLetter.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.buildByWord, action: /Action.buildByWord) {
            BuildByWord()
        }
        Scope(state: /State.buildByLetter, action: /Action.buildByLetter) {
            BuildByLetter()
        }
    }
}

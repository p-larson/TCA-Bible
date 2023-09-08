import ComposableArchitecture
import BibleCore
import BibleClient

struct BuildByLetter: Reducer {
    enum Difficulty: Equatable, Codable {
        case easy, medium, hard
    }
    
    struct State: Equatable, Codable {
        var difficulty: Difficulty
        var verses: [Verse]
        
        var correctAnswer: [String] {
            verses
                .map(\.verse)
                .joined(separator: " ")
                .split(separator: " ")
                .map(String.init)
        }
        var answer: [String?]
        var wordBank: [String]
    }
    
    enum Action {
        case task
    }
    
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator: WithRandomNumberGenerator
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.wordBank = withRandomNumberGenerator {
                    state.correctAnswer.shuffled(using: &$0)
                }
                
                return .none
            }
        }
    }
    
    
}

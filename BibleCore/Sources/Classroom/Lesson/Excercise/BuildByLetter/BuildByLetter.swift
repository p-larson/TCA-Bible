import ComposableArchitecture
import BibleCore
import BibleClient

struct BuildByLetter: Reducer {
    
    struct State: Equatable, Codable, Hashable {
        var verses: [Verse]
        var answer: [String?]? = nil
        var wordBank: [String] = []
        
        var correctAnswer: [String] {
            verses
                .map(\.verse)
                .joined(separator: " ")
                .split(separator: " ")
                .map(String.init)
        }

        init(
            verses: [Verse],
            answer: [String?]? = nil,
            wordBank: [String] = []
        ) {
            self.verses = verses
            self.answer = answer
            self.wordBank = wordBank
        }
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

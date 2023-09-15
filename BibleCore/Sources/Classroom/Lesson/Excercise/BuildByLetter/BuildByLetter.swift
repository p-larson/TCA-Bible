import ComposableArchitecture
import BibleCore
import BibleClient

public struct BuildByLetter: Reducer {
    public init () {}
    
    public struct State: Equatable, Codable, Hashable, ExerciseProtocol {
        var isCorrect: Bool {
            false
        }
        
        var score: Int {
            0
        }
        
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

        public init(
            verses: [Verse],
            answer: [String?]? = nil,
            wordBank: [String] = []
        ) {
            self.verses = verses
            self.answer = answer
            self.wordBank = wordBank
        }
    }
    
    public enum Action {
        case task
    }
    
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator: WithRandomNumberGenerator
    
    public var body: some ReducerOf<Self> {
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

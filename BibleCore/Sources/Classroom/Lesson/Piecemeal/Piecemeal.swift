import ComposableArchitecture
import BibleCore
import BibleClient

public struct Piecemeal: Reducer {
    public init() {}
    
    public struct State: Equatable, Codable {
        var verses: [Verse]? = nil
        var error: ClassroomError? = nil
        var wordBank = [String]()
        var answer = [String]()
        
        var correctAnswer: [String] {
            guard let verses = verses else {
                return []
            }
            
            return verses.map(\.verse)
                .joined(separator: " ")
                .split(separator: " ")
                .map(String.init)
        }
        
        var isCorrect: Bool {
            guard verses != nil else {
                return false
            }
            
            return correctAnswer.elementsEqual(answer)
        }
        
        public struct ClassroomError: Equatable, Codable {
            let title, message: String
            
            init(title: String, message: String) {
                self.title = title
                self.message = message
            }
            
            static let basic = Self(
                title: "Could not load",
                message: "Please check your internet and retry."
            )
        }
        
        init(
            verses: [Verse]? = nil,
            error: ClassroomError? = nil,
            wordBank: [String] = [String](),
            answer: [String] = [String]()
        ) {
            self.verses = verses
            self.error = error
            self.wordBank = wordBank
            self.answer = answer
        }
    }
    
    public enum Action: Equatable {
        case task
        case setup([Verse])
        case failedSetup(error: State.ClassroomError)
        case guess(index: Int)
        case check
        case didComplete
    }
    
    @Dependency(\.bible) var bible: BibleClient
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                // If this classroom session is not created with a select verses in mind,
                // we want to go fetch a random verse to start learning from.
                
                guard state.verses == nil else {
                    return .none
                }
                
                
                // Grab a random verse to learn
                return .run { send in
                    guard
                        let book = try? await bible.books()
                            .randomElement(),
                        let chapter = try? await bible.chapters(
                            book.id
                        ).randomElement(),
                        let verse = try? await bible.verses(
                            book.id,
                            chapter.id
                        ).randomElement()
                    else {
                        await send(.failedSetup(error: .basic))
                        return
                    }
                    
                    await send(.setup([verse]))
                }
            case .setup(let verses):
                state.verses = verses
                
                state.wordBank = withRandomNumberGenerator {
                    state.correctAnswer.shuffled(using: &$0)
                }
                state.answer = []
                
                return .none
            case .failedSetup(let error):
                
                state.error = error
                
                return .none
            case .guess(let index):
                let guess = state.wordBank.remove(at: index)
                
                state.answer.append(guess)
                
                return .none
            case .check:
                if state.isCorrect {
                    return .send(.didComplete)
                }
                
                return .none
            case .didComplete:
                print("Hazzah!")
                return .none
            }
        }
    }
}

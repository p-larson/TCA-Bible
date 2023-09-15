import ComposableArchitecture
import BibleCore
import BibleClient
import Foundation

public struct BuildByWord: Reducer {
    public init() {}
    
    public struct State: Equatable, Codable, Hashable, ExerciseProtocol {
        
        public struct Guess: Equatable, Identifiable, Codable, Hashable {
            let word: String
            public let id: UUID
            
            init(word: String, id: UUID) {
                self.word = word
                self.id = id
            }
        }
        
        var verses: [Verse]? = nil
        var error: ClassroomError? = nil
        var wordBank = IdentifiedArrayOf<Guess>()
        var answer = IdentifiedArrayOf<Guess>()
        
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
            
            return correctAnswer.elementsEqual(answer.map(\.word))
        }
        
        var score: Int { 0 }
        
        public struct ClassroomError: Equatable, Codable, Hashable {
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
        
        init(verses: [Verse]? = nil, error: ClassroomError? = nil, wordBank: IdentifiedArrayOf<Guess> = IdentifiedArrayOf<Guess>(), answer: IdentifiedArrayOf<Guess> = IdentifiedArrayOf<Guess>()) {
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
        case guess(id: UUID)
        case remove(id: UUID)
    }
    
    @Dependency(\.bible) var bible: BibleClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                // If this classroom session is not created with a select verses in mind,
                // we want to go fetch a random verse to start learning from.
                
                guard state.verses == nil else {
                    return .send(.setup(state.verses!))
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
                
                state.wordBank = IdentifiedArray(uniqueElements: withRandomNumberGenerator { (generator) -> [State.Guess] in
                    return state.correctAnswer.shuffled(using: &generator).map { (word) -> State.Guess in
                        return State.Guess.init(word: word, id: uuid())
                    }
                })
                
                state.answer = []
                
                return .none
            case .failedSetup(let error):
                
                state.error = error
                
                return .none
            case .guess(let id):
                state.answer.append(state.wordBank.remove(id: id)!)
                return .none
            case .remove(let id):
                state.wordBank.append(state.answer.remove(id: id)!)
                return .none
            }
        }
    }
}

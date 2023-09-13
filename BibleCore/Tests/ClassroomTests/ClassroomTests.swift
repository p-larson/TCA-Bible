import ComposableArchitecture
import XCTest

@testable import Classroom

@MainActor
final class ClassroomTests: XCTestCase {
    
    var store: TestStoreOf<BuildByWord>!
    
    var wordBank: [String]!
    
    override func setUp() async throws {
        store = TestStore(initialState: BuildByWord.State()) {
            BuildByWord()
        } withDependencies: {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(LCRNG(seed: 0))
            $0.uuid = .incrementing
        }
        
        wordBank = ["In", "created", "the","heavens","the","God","and","the","earth.","beginning"]
        
        await store.send(.task)
        
        await store.receive(.setup(.mock)) {
            $0.verses = .mock
            $0.wordBank = IdentifiedArray(
                uniqueElements: self.wordBank.map { word in
                    BuildByWord.State.Guess(word: word, id: self.store.dependencies.uuid())
                }
            )
        }
    }

    func testSetup() async {
        XCTAssertFalse(store.state.isCorrect)
    }
    
    func testCorrectGuessing() async {
        var copy = store.state.wordBank
        var correctOrder = [UUID]()
        
        store.state.correctAnswer.forEach { word in
            let id = copy.first { guess in
                guess.word == word
            }?.id
            
            copy.remove(id: id!)
            
            correctOrder.append(id!)
        }
        
        var answer = IdentifiedArrayOf<BuildByWord.State.Guess>()
        
        for id in correctOrder {
            // Always fail until the last guess is made.
            XCTAssertFalse(store.state.isCorrect)
            
            await store.send(.guess(id: id)) {
                let guess = $0.wordBank.remove(id: id)
                
                answer.append(guess!)
                
                $0.answer = answer
            }
        }
        
        XCTAssertTrue(store.state.isCorrect)
    }
    // TODO: Re-implement
//
//    func testIncorrectGuessing() async {
//        let incorrectGuesses = store.state.correctAnswer.map { _ in return 0 }
//
//        var answer = IdentifiedArrayOf<BuildByWord.State.Guess>()
//
//        for id in incorrectGuesses {
//            // Always fail until the last guess is made.
//            XCTAssertFalse(store.state.isCorrect)
//
//            await store.send(.guess(id: id)) {
//                let word = $0.wordBank.remove(id: id)
//                answer.append(word)
//                $0.answer = answer
//            }
//        }
//
//        XCTAssertFalse(store.state.isCorrect)
//    }

}

// Taken from somewhere in PointFreeCo's CaseStudy
// Bad random number generator = predictable = good for testing :)

/// A linear congruential random number generator.
struct LCRNG: RandomNumberGenerator {
    var seed: UInt64
    
    init(seed: UInt64 = 0) {
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        self.seed = 2_862_933_555_777_941_757 &* self.seed &+ 3_037_000_493
        return self.seed
    }
}

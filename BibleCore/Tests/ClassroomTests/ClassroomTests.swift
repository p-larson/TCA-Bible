import ComposableArchitecture
import XCTest

@testable import Classroom

@MainActor
final class ClassroomTests: XCTestCase {
    
    var store: TestStoreOf<Piecemeal>!
    
    var wordBank: [String]!
    
    override func setUp() async throws {
        store = TestStore(initialState: Piecemeal.State()) {
            Piecemeal()
        } withDependencies: {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(LCRNG(seed: 0))
        }
        
        wordBank = ["In", "created", "the","heavens","the","God","and","the","earth.","beginning"]
        
        await store.send(.task)
        
        await store.receive(.setup(.mock)) {
            $0.verses = .mock
            $0.wordBank = self.wordBank
        }
    }

    func testSetup() async {
        XCTAssertFalse(store.state.isCorrect)
    }
    
    func testCorrectGuessing() async {
        var copy = store.state.wordBank
        var correctGuessOrder = [Int]()
        
        store.state.correctAnswer.forEach {
            let index = copy.firstIndex(of: $0)!
            
            copy.remove(at: index)
            
            correctGuessOrder.append(index)
        }
        
        var answer = [String]()
        
        for guess in correctGuessOrder {
            // Always fail until the last guess is made.
            XCTAssertFalse(store.state.isCorrect)
            
            await store.send(.guess(index: guess)) {
                let word = $0.wordBank.remove(at: guess)
                answer.append(word)
                $0.answer = answer
            }
        }
        
        XCTAssertTrue(store.state.isCorrect)
    }
    
    func testIncorrectGuessing() async {
        let incorrectGuesses = store.state.correctAnswer.map { _ in return 0 }
        
        var answer = [String]()
        
        for guess in incorrectGuesses {
            // Always fail until the last guess is made.
            XCTAssertFalse(store.state.isCorrect)
            
            await store.send(.guess(index: guess)) {
                let word = $0.wordBank.remove(at: guess)
                answer.append(word)
                $0.answer = answer
            }
        }
        
        XCTAssertFalse(store.state.isCorrect)
    }

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

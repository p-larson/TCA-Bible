//import BibleCore
//import ComposableArchitecture
//import Foundation
//
//struct BuildByBabySteps: Reducer {
//    struct State: Equatable, Hashable, Codable {
//        var verses: [Verse]
//        var options: [String]? = nil
//        var currentPhrase: [String] = []
//        
//        init(verses: [Verse], options: [String]? = nil, currentPhrase: [String] = []) {
//            
//            precondition(verses.complete.count != currentPhrase.count)
//            
//            self.verses = verses
//            self.options = options
//            self.currentPhrase = currentPhrase
//        }
//    }
//    
//    enum Action: Equatable {
//        case setup([Verse], [String])
//        case guess(id: UUID)
//    }
//    
//    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
//    
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .guess(id: let id):
//                state.currentPhrase.append(state.word)
////                state.currentPhrase.append(guess)
////                state.currentPhrase.append(<#T##newElement: String##String#>)
//                
//                return .none
//            case .setup(let verses, let currentPhrases):
//                
//                state.verses = verses
//                state.currentPhrase = currentPhrases
//                
//                var options = [String]()
//                var copy = verses.complete
//            
//                // Correct option
//                options.append(copy.remove(at: currentPhrases.count))
//                
//                // Add  1-3 other options if available
//                repeat {
//                    withRandomNumberGenerator {
//                        copy.shuffle(using: &$0)
//                    }
//                    
//                    if let element = copy.popLast() {
//                        options.append(element)
//                    }
//                    
//                } while !copy.isEmpty && options.count < 4
//                
//                return .none
//            }
//            
//        }
//    }
//}
//
//extension BuildByBabySteps.State: ExerciseProtocol {
//    var score: Int {
//        maxScore
//    }
//    
//    var isCorrect: Bool {
//        
//        return verses
//            .map(\.verse)
//            .joined(separator: " ")
//            .split(separator: " ")
//            .map(String.init)
//            .elementsEqual(currentPhrase)
//            
//    }
//}

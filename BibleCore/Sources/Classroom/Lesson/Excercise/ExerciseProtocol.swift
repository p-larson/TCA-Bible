import Foundation

protocol ExerciseProtocol {
    var isCorrect: Bool { get }
    var score: Int { get }
    var maxScore: Int { get }
}

extension ExerciseProtocol {
    var maxScore: Int { return 10 }
}

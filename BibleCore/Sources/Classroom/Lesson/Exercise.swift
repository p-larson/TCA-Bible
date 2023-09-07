import BibleCore
import ComposableArchitecture

struct Exercise: Reducer {
    
    enum State: Equatable, Codable {
        case piecemeal(Piecemeal.State)
        case fillInTheBlank(FillInTheBlank.State)
    }
    
    enum Action: Equatable {
        case piecemeal(Piecemeal.Action)
        case fillInTheBlank(FillInTheBlank.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

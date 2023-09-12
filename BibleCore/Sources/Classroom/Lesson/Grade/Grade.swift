import ComposableArchitecture

struct Grade: Reducer {
    enum State: Equatable, Codable, Hashable {
        case disabled
        case ready
        case failed(String)
        case partial(String)
        case correct
    }
    
    enum Action: Equatable {
        case next
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .next:
                return .none
            }
        }
    }
}

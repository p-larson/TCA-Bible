import ComposableArchitecture

struct Grade: Reducer {
    enum State: Equatable, Codable {
        case disabled
        case ready
        case failed(String)
        case partial(String)
        case correct
    }
    
    enum Action: Equatable {
        case submit
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .submit:
                return .none
            }
        }
    }
}

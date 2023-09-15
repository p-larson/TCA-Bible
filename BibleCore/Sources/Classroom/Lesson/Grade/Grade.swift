import ComposableArchitecture

public struct Grade: Reducer {
    public init () {}
    
    public enum State: Equatable, Codable, Hashable {
        case disabled
        case ready
        case failed(String)
        case partial(String)
        case correct
    }
    
    public enum Action: Equatable {
        case didPressButton
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in .none }
    }
}

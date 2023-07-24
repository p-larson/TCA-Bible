// https://gist.github.com/taskcruncher/a482883eab0f8cf07b2f7d86bbd48004

import SwiftUI
import ComposableArchitecture

@dynamicMemberLookup

struct BaseState<SharedState: Equatable, State: Equatable>: Equatable{
    var sharedState: SharedState
    var state: State
    
    init(sharedState:  SharedState, state: State){
        self.sharedState = sharedState
        self.state = state
    }
    // https://www.swiftbysundell.com/tips/combining-dynamic-member-lookup-with-key-paths/
    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
        set { state[keyPath: keyPath] = newValue }
    }
    
}

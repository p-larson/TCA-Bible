import BibleComponents
import ComposableArchitecture
import SwiftUI

import WrappingHStack

public struct BuildByWordView: View {
    public let store: StoreOf<BuildByWord>
    
    public init(store: StoreOf<BuildByWord>) {
        self.store = store
    }
    
    @Namespace var namespace
    
    @State var foo = false
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 32) {
                Text("Classroom")
                    .font(.largeTitle)
                
                WrappingHStack(alignment: .leading) {
                    ForEach(viewStore.answer) { guess in
                        Button(guess.word) {
                            viewStore.send(.remove(id: guess.id))
                        }
                        .buttonStyle(.option)
                            .matchedGeometryEffect(id: guess.id, in: namespace, properties: .position)
                    }
                }
                
                Spacer()
                
                WrappingHStack {
                    ForEach(viewStore.wordBank) { guess in
                        Button(guess.word) {
                            viewStore.send(.guess(id: guess.id), animation: .easeOut(duration: 0.3))
                        }
                        .buttonStyle(.option)
                        .matchedGeometryEffect(id: guess.id, in: namespace, isSource: true)
                    }
                }

            }
            .task { viewStore.send(.task) }
            .padding(.horizontal)
        }
    }
}

struct BuildByWordView_Previews: PreviewProvider {
    static var previews: some View {
        BuildByWordView(
            store: Store(
                initialState: BuildByWord.State(),
                reducer: {
                    BuildByWord()
                        .dependency(\.bible, .testValue)
                        ._printChanges()
                }
            )
        )
        .previewDevice("iPhone 14")
    }
}

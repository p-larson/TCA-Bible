import BibleComponents
import ComposableArchitecture
import SwiftUI

import WrappingHStack

public struct BuildByWordView: View {
    public let store: StoreOf<BuildByWord>
    
    public init(store: StoreOf<BuildByWord>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 32) {
                Text("Classroom")
                    .font(.largeTitle)
                
                WrappingHStack {
                    ForEach(viewStore.answer, id: \.self) { guess in
                        Text(guess)
                    }
                }
                
                Spacer()
                
                WrappingHStack {
                    ForEach(viewStore.wordBank.enumerated().map(\.offset), id: \.self) { index in
                        
                        Button(viewStore.wordBank[index]) {
                            viewStore.send(.guess(index: index))
                        }
                        .buttonStyle(.option)
                        
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

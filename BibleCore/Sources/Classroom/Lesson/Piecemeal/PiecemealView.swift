import ComposableArchitecture
import SwiftUI

import WrappingHStack

public struct PiecemealView: View {
    public let store: StoreOf<Piecemeal>
    
    public init(store: StoreOf<Piecemeal>) {
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
                
                if viewStore.wordBank.isEmpty {
                    
                } else {
                    WrappingHStack {
                        ForEach(viewStore.wordBank.enumerated().map(\.offset), id: \.self) { index in
                            Button {
                                viewStore.send(.guess(index: index))
                            } label: {
                                Text(viewStore.wordBank[index])
                                    .padding()
                                    .foregroundColor(.black)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12, style: .circular)
                                            .stroke(lineWidth: 2)
                                            .foregroundColor(Color.black.opacity(1/5))
                                            .shadow(color: Color.black.opacity(1/5), radius: 5, x: 5, y: 5)
                                    }
                            }

                        }
                    }
                }
                
                Button {
                    viewStore.send(.check)
                } label: {
                    Text("Check")
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .circular)
                                .foregroundColor(viewStore.answer.isEmpty ? .gray : .green)
                        }
                }
                .disabled(viewStore.answer.isEmpty)

            }
            .task { viewStore.send(.task) }
            .padding(.horizontal)
        }
    }
}

struct PiecemealView_Previews: PreviewProvider {
    static var previews: some View {
        PiecemealView(
            store: Store(
                initialState: Piecemeal.State(),
                reducer: {
                    Piecemeal()
                        .dependency(\.bible, .testValue)
                }
            )
        )
        .previewDevice("iPhone 14")
    }
}

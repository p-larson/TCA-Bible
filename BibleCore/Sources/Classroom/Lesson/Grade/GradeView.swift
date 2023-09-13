import BibleComponents
import ComposableArchitecture
import SwiftUI

fileprivate extension View {
    
    @ViewBuilder
    func buttonStyle(for grade: Grade.State) -> some View {
        switch grade {
        case .correct:
            self.buttonStyle(.correct)
        case .disabled:
            self.buttonStyle(.disabled)
        case .ready:
            self.buttonStyle(.correct)
        case .failed(_):
            self.buttonStyle(.unselected)
        case .partial(_):
            self.buttonStyle(.unselected)
        }
    }
    
    @ViewBuilder
    func foreground(for grade: Grade.State) -> some View {
        switch grade {
        case .correct:
            self.foregroundColor(.darkGreen)
        case .disabled:
            self.foregroundColor(.darkGreen)
        case .ready:
            self.foregroundColor(.darkGreen)
        case .failed(_):
            self.foregroundColor(.darkGreen)
        case .partial(_):
            self.foregroundColor(.darkGreen)
        }
    }
    
    @ViewBuilder
    func hidden(for grade: Grade.State) -> some View {
        switch grade {
        case .correct:
            self
        default:
            self.hidden()
        }
    }
}

fileprivate extension String {
    static func title(for grade: Grade.State) -> String {
        switch grade {
        case .correct:
            return "Nice Job"
        default: return String()
        }
    }
}

struct GradeView: View {
    let store: StoreOf<Grade>
    
    var body: some View {
        SwitchStore(store) { initialState in
            VStack(alignment: .leading) {
                Text(String.title(for: initialState))
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foreground(for: initialState)
                    .hidden(for: initialState)
                Button("check") {
                    store.send(.next)
                }
                .buttonStyle(for: initialState)
            }
            .padding()
            .background {
                switch initialState {
                case .correct:
                    Color.softGreen
                        .transition(.move(edge: .bottom))
                        .edgesIgnoringSafeArea(.bottom)
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct GradeView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(
            [Grade.State.correct, Grade.State.ready, Grade.State.disabled],
            id: \.self
        ) { grade in
            VStack {
                Spacer()
                GradeView(store: Store(initialState: grade) {
                    Grade()
                        ._printChanges()
                })
            }
        }
    }
}

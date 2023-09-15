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
    
    static func text(for grade: Grade.State) -> String {
        switch grade {
        case .correct:
            return "Next"
        case .ready:
            return "Check"
        default:
            return "Check"
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
                    .transition(.move(edge: .bottom))
                Button(String.text(for: initialState)) {
                    store.send(.didPressButton, animation: .easeOut(duration: 0.3))
                }
                .buttonStyle(for: initialState)
                .transaction { $0.animation = nil }
            }
            .padding()
            .background {
                switch initialState {
                case .correct:
                    Color.softGreen
                        .edgesIgnoringSafeArea(.bottom)
                        .transition(.move(edge: .bottom))
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct GradeView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            Spacer()
            GradeView(store: Store(initialState: .correct) {
                Reduce<Grade.State, Grade.Action> { state, action in
                    
//                    state = .disabled
                    
                    return .none
                }
            })
        }
        
        
        VStack {
            Spacer()
            GradeView(store: Store(initialState: .ready) {
                Reduce<Grade.State, Grade.Action> { state, action in
                    
                    state = .correct
                    
                    return .none
                }
            })
        }
    }
}

import BibleComponents
import ComposableArchitecture
import SwiftUI

struct LessonView: View {
    
    let store: StoreOf<Lesson>
    
    init(store: StoreOf<Lesson>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                }
                .controlSize(.large)
                .foregroundColor(.black)
                
                WithViewStore(store, observe: \.score) {
                    ProgressBar(progress: $0.state)
                }

            }
            .padding(.horizontal)
            
            IfLetStore(
                store.scope(state: \.exercise, action: Lesson.Action.excercise),
                then: ExerciseView.init(store:)
            ) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                )
                .combined(with: .opacity)
            )
            
            Spacer()
            
            GradeView(store: store.scope(state: \.grade, action: Lesson.Action.grade))
        }
        .onAppear {
            store.send(.prepare)
        }
    }
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView(
            store: Store(initialState: Lesson.State.init(verses: .mock)) {
                Lesson()
                    .dependency(\.bible, .testValue)
                    ._printChanges()
            }
        )
    }
}

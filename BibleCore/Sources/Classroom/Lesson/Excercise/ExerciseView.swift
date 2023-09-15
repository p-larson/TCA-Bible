import ComposableArchitecture
import SwiftUI

struct ExerciseView: View {
    let store: StoreOf<Exercise>
    
    var body: some View {
        SwitchStore(store) { initialState in
            switch initialState {
            case .buildByLetter:
                CaseLet(
                    /Exercise.State.buildByLetter, action: Exercise.Action.buildByLetter,
                     then: BuildByLetterView.init(store:)
                )
            case .buildByWord:
                CaseLet(
                    /Exercise.State.buildByWord, action: Exercise.Action.buildByWord,
                     then: BuildByWordView.init(store:)
                )
            }
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(
            store: Store(initialState: Exercise.State.buildByWord(.init(verses: .mock))) {
                Exercise()
                    ._printChanges()
            }
        )
    }
}

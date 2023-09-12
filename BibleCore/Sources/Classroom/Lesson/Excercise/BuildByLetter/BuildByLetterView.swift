import ComposableArchitecture
import SwiftUI

struct BuildByLetterView: View {
    
    let store: StoreOf<BuildByLetter>
    
    init(store: StoreOf<BuildByLetter>) {
        self.store = store
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BuildByLetterView_Previews: PreviewProvider {
    static var previews: some View {
        BuildByLetterView(
            store: Store(
                initialState: BuildByLetter.State(
                    verses: .mock
                )
            ) {
                BuildByLetter()
            }
        )
    }
}

import ComposableArchitecture
import SwiftUI

struct ClassroomView: View {
    let store: StoreOf<Classroom>
    
    var body: some View {
        EmptyView()
    }
}

struct ClassroomView_Previews: PreviewProvider {
    static var previews: some View {
        ClassroomView(
            store: Store(initialState: Classroom.State()) {
                Classroom()
            }
        )
    }
}

import ComposableArchitecture
import SwiftUI

struct ClassroomView: View {
    let store: StoreOf<Classroom>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
        }
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

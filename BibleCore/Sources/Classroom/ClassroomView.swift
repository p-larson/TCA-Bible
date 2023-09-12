import ComposableArchitecture
import DirectoryCore
import SwiftUI

struct ClassroomView: View {
    
    let store: StoreOf<Classroom>
    @ObservedObject var viewStore: ViewStoreOf<Classroom>
    
    init(store: StoreOf<Classroom>) {
        self.store = store
        self.viewStore = ViewStoreOf<Classroom>(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEachStore(
                    store.scope(
                        state: \.lessons,
                        action: Classroom.Action.lesson(id:action:)
                    ),
                    content: { store in
                        Text("foo")
                    }
                )
            }
            .navigationDestination(for: Lesson.State.self, destination: { lesson in
                Text("foo")
            })
            .listStyle(.inset)
            .navigationTitle("Classroom")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.openDirectory)
                    } label: {
                        Text("Add")
                    }
                }
            }
            .popover(isPresented: viewStore.$isDirectoryOpen, content: {
                IfLetStore(
                    store.scope(
                        state: \.directory,
                        action: Classroom.Action.directory
                    ), then: { store in
                        NavigationStack {
                            DirectoryView(store: store)
                        }
                    }
                ) {
                    ProgressView()
                }
            })
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

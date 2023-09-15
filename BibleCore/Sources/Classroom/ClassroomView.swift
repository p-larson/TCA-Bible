import ComposableArchitecture
import DirectoryCore
import SwiftUI

public struct ClassroomView: View {
    
    let store: StoreOf<Classroom>
    
    @ObservedObject var viewStore: ViewStoreOf<Classroom>
    
    public init(store: StoreOf<Classroom>) {
        self.store = store
        self.viewStore = ViewStoreOf<Classroom>(store, observe: { $0 })
    }
    
    public var body: some View {
        
        NavigationStackStore(store.scope(state: \.path, action: Classroom.Action.path)) {
            List {
                ForEach(viewStore.lessons) { lesson in
                    Button {
                        viewStore.send(.select(id: lesson.id))
                    } label: {
                        Text(lesson.id.description)
                    }
                }
            }
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
        } destination: { store in
            switch store {
            case .lesson:
                CaseLet(
                    /Classroom.Path.State.lesson,
                     action: Classroom.Path.Action.lesson,
                     then: LessonView.init(store:)
                )
                .navigationBarBackButtonHidden()
                // case .message(let text):
                //    Text(text)
                
            }
        }
    }
}

struct ClassroomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ClassroomView(
                store: Store(initialState: Classroom.State(
                    lessons: [.init(verses: .mock)]
                )) {
                    Classroom()
                }
            )
        }
    }
}

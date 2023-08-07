import BibleCore
import ComposableArchitecture
import SwiftUI

struct PageView: View {
    let store: StoreOf<Page>
    
    func swipe(store: ViewStoreOf<Page>) -> some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width < 0 {
                    store.send(.paginateChapter(forward: true))
                } else {
                    store.send(.paginateChapter(forward: false))
                }
            }
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack(alignment: .leading) {
                        ForEach(viewStore.isRedacted ? [.mock] : viewStore.verses!) { (content: Verse) in
                            HStack(alignment: .top, spacing: 8) {
                                Text(content.verseId.description)
                                    .bold()
                                Text(content.verse)
                            }
                            .frame(alignment: .top)
                            .onTapGesture {
                                viewStore.send(.select(content))
                            }
                            .id(content.id)
                            .transition(
                                AnyTransition.asymmetric(
                                    insertion: .opacity,
                                    removal: .identity
                                )
                            )
                        }
                        .onChange(of: viewStore.verse) { newValue in
                            withAnimation(.easeOut(duration: 0.3)) {
                                reader.scrollTo(newValue?.id, anchor: .top)
                            }
                        }
                        .redacted(reason: viewStore.isRedacted ? .placeholder : [])
                    }
                    .padding(.horizontal)
                }
            }
            .task {
                viewStore.send(.task)
            }
            .gesture(swipe(store: viewStore))
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PageView(store: Store(initialState: Page.State()) {
                Page()
            })
            .previewDevice("iPhone 14")
            .previewDisplayName("Mobile")
            
            PageView(store: Store(initialState: Page.State()) {
                Page()
            })
            .previewLayout(.sizeThatFits)
            .previewDevice("Mac")
            .previewDisplayName("Desktop")
        }
    }
}

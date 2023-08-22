import ComposableArchitecture
import DirectoryCore
import SwiftUI

public struct DesktopReaderView: View {
    let store: StoreOf<DesktopReader>
    
    public init(store: StoreOf<DesktopReader>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0} ) { viewStore in
            PageView(store: store.scope(state: \.page, action: DesktopReader.Action.page))
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.navigation) {
                        ToolbarDirectoryView(
                            store: store.scope(
                                state: \.toolbarDirectory,
                                action: DesktopReader.Action.toolbarDirectory
                            )
                        )
                    }
                }
                .overlay {
                    HStack {
                        Button {
                            viewStore.send(.page(.paginateChapter(forward: false)))
                        } label: {
                            Image(systemName: "arrow.left")
                        }
                        .keyboardShortcut(.leftArrow)
                        Spacer()
                        Button {
                            viewStore.send(.page(.paginateChapter(forward: true)))
                        } label: {
                            Image(systemName: "arrow.right")
                        }
                        .keyboardShortcut(.rightArrow)
                     }
                    .padding()
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
        }
    }
}

struct DesktopReaderView_Previews: PreviewProvider {
    static var previews: some View {
        DesktopReaderView(
            store: Store(initialState: DesktopReader.State()) {
                DesktopReader()
            }
        )
    }
}

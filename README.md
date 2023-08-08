# TCA-Bible
[![Swift](https://github.com/p-larson/TCA-Bible/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/p-larson/TCA-Bible/actions/workflows/swift.yml)

This project is solely a demonstration of a multiplatform `iOS`/`macOS` application built with `SwiftUI` and `TCA`. Both apps are distinct, but they do share a majority of their code-base. Using `TCA` to hyper-modularize this project has allowed the two targets to share the most feasible amount of depenedencies, which has been a huge advantage.

- [iOS](#iOS)
- [macOS](#Mac)
- [Source](#Source)
- [Tests](#Tests)
- [More](#More)

## iOS

<img src="https://github.com/p-larson/TCA-Bible/blob/main/Bible/Simulator%20Screenshot%20-%20iPhone%2014%20-%202023-08-08%20at%2012.12.20.png" width=225> <img src="https://github.com/p-larson/TCA-Bible/blob/main/Bible/Simulator%20Screenshot%20-%20iPhone%2014%20-%202023-08-08%20at%2012.12.27.png" width=225> <img src="https://github.com/p-larson/TCA-Bible/blob/main/Bible/Simulator%20Screenshot%20-%20iPhone%2014%20-%202023-08-08%20at%2012.12.32.png" width=225> 

## Mac

<img src="https://github.com/p-larson/TCA-Bible/blob/main/Bible/Screenshot%202023-08-08%20at%2012.11.55%20PM.png" width=600>

## Source

- [BibleClient](BibleCore/Sources/BibleClient/)
- [BibleClient/Client.swift](BibleCore/Sources/BibleClient/Client.swift)
- [BibleClient/Live.swift](BibleCore/Sources/BibleClient/Live.swift)
- [BibleClient/Test.swift](BibleCore/Sources/BibleClient/Test.swift)
- [BibleCore/](BibleCore/Sources/BibleCore)
- [BibleCore/Book.swift](BibleCore/Sources/BibleCore/Book.swift)
- [BibleCore/Chapter.swift](https://github.com/p-larson/TCA-Bible/blob/main/BibleCore/Sources/BibleCore/Chapter.swift)
- [BibleCore/Genre.swift](https://github.com/p-larson/TCA-Bible/blob/main/BibleCore/Sources/BibleCore/Genre.swift)
- [BibleCore/Translation.swift](https://github.com/p-larson/TCA-Bible/blob/main/BibleCore/Sources/BibleCore/Translation.swift)
- [BibleCore/Verse.swift](https://github.com/p-larson/TCA-Bible/blob/main/BibleCore/Sources/BibleCore/Verse.swift)
- [DirectoryCore/](BibleCore/Sources/DirectoryCore/)
- [DirectoryCore/MenuDirectory](BibleCore/Sources/DirectoryCore/MenuDirectory/)
- [DirectoryCore/MenuDirectory/MenuDirectory.swift](BibleCore/Sources/DirectoryCore/MenuDirectory/MenuDirectory.swift)
- [DirectoryCore/MenuDirectory/MenuDirectoryView.swift](BibleCore/Sources/DirectoryCore/MenuDirectory/MenuDirectoryView.swift)
- [DirectoryCore/MenuDirectory/Section/](BibleCore/Sources/DirectoryCore/MenuDirectory/Section/)
- [DirectoryCore/MenuDirectory/Section/Section.swift](BibleCore/Sources/DirectoryCore/MenuDirectory/Section/Section.swift)
- [DirectoryCore/MenuDirectory/Section/SectionView.swift](BibleCore/Sources/DirectoryCore/MenuDirectory/Section/SectionView.swift)
- [DirectoryCore/ToolbarDirectory/ToolDirectory.swift](BibleCore/Sources/DirectoryCore/ToolDirectory/ToolDirectory.swift)
- [DirectoryCore/ToolbarDirectory/ToolDirectoryView.swift](BibleCore/Sources/DirectoryCore/ToolDirectory/ToolDirectoryView.swift)
- [ReaderCore/DesktopReader/DesktopReader.swift](BibleCore/Sources/ReaderCore/DesktopReader/DesktopReader.swift)
- [ReaderCore/DesktopReader/DesktopReaderView.swift](BibleCore/Sources/ReaderCore/DesktopReader/DesktopReaderView.swift)
- [ReaderCore/Page/Page.swift](BibleCore/Sources/ReaderCore/Page/Page.swift)
- [ReaderCore/Page/PageView.swift](BibleCore/Sources/ReaderCore/Page/PageView.swift)
- [ReaderCore/Reader.swift](BibleCore/Sources/ReaderCore/Reader.swift)

## Tests

- [AppStoreSnapshotTests](BibleCore/Tests/AppStoreSnapshotTests/)
- [BibleClientTests](BibleCore/Tests/BibleClientTests/)
- [DirectoryCoreTests](BibleCore/Tests/DirectoryCoreTests/)
- [ReaderCoreTests](BibleCore/Tests/ReaderCoreTests/)

## More

## My favorite lines of code from this project 💖
*Exhaustive testing with `TCA`*

```swift
// BibleCore/Tests/ReaderCoreTests/ReaderTests.swift#testNextChapter:82-84
await store.send(.menuDirectory(.book(id: Book.genesis.id, action: .select(.genesis, .mock, .mock, nil)))) {
    $0.isDirectoryOpen = false
}
```

## My least favorite lines of code from this project 😪

*Optional SwiftUI.View#tag*

```swift
// BibleCore/Source/DirectoryCore/ToolbarDirectory/ToolbarDirectoy.swift:23
// viewStore.$book: Optional<Book>
Picker(selection: viewStore.$book) { 
  ForEach(books) { book in
      Text(book.name)
        // This is beyond the silliest part of SwiftUI.
        // BindingState<Optional<Book>> requires tag to SwiftUI.View#tag to be Optional<Book>
        // otherwise, Optional<Book> equate to Book will always fail.
        .tag(Book?.some(book))
  }
}
...
```

![Screenshot](https://github.com/p-larson/TCA-Bible/blob/8bd75df0745db54b19872276254748b5f34fbb8b/Bible/Screenshot%202023-07-24%20at%203.00.01%20PM.png)
![Screenshot 2](https://github.com/p-larson/TCA-Bible/blob/4489929085ec83cf05939f2f938e3518d6d40e72/Bible/Screenshot%202023-07-24%20at%203.04.00%20PM.png)

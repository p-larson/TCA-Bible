import Foundation

public typealias VerseID = Int

public struct Verse: Equatable, Codable, Identifiable, Hashable {
    public let id: VerseID
    public let book: Book
    public let chapterId: ChapterID
    public let verseId: VerseID
    public let verse: String
    
    public init(
        id: VerseID,
        book: Book,
        chapterId: ChapterID,
        verseId: VerseID,
        verse: String
    ) {
        self.id = id
        self.book = book
        self.chapterId = chapterId
        self.verseId = verseId
        self.verse = verse
    }
}

public extension Verse {
    static var mock: Self {
        .init(id: 1, book: .genesis, chapterId: 1, verseId: 1, verse: "In the beginning God created the heavens and the earth.")
    }
}

public extension Array where Element == Verse {
    static var mock: [Verse] {
        [.mock]
    }
    
    var complete: [String] {
        self.map(\.verse)
            .joined(separator: " ")
            .split(separator: " ")
            .map(String.init)
    }
}

import Foundation

public typealias ID = Int

public typealias TranslationID = ID
public typealias BookID = ID
public typealias GenreID = ID
public typealias ChapterID = ID
public typealias VerseID = ID

public struct Genre: Equatable, Codable, Identifiable, Hashable {
    public let id: GenreID
    public let name: String
    
    public init(id: ID, name: String) {
        self.id = id
        self.name = name
    }
    
    public static var mock: Self {
        .init(id: 0, name: "grace")
    }
}

public struct Translation: Equatable, Codable, Identifiable, Hashable {
    public let id: TranslationID
    public let language: String
    public let abbreviation: String
    public let version: String
    public let infoUrl: String
    
    public init(
        id: TranslationID,
        language: String,
        abbreviation: String,
        version: String,
        infoUrl: String
    ) {
        self.id = id
        self.language = language
        self.abbreviation = abbreviation
        self.version = version
        self.infoUrl = infoUrl
    }
}

public extension Translation {
    static var mock: Self {
        .init(id: 0, language: "en", abbreviation: "NIV", version: "1.0", infoUrl: "bible.com")
    }
}

public extension Array where Element == Translation {
    static var mock: [Translation] {
        [.mock]
    }
}

public struct Book: Equatable, Codable, Identifiable, Hashable {
    public let id: BookID
    public let name: String
    public let testament: String
    
    public init(
        id: BookID,
        name: String,
        testament: String
    ) {
        self.id = id
        self.name = name
        self.testament = testament
    }
}

public extension Book {
    static var genesis: Self {
        .init(id: 1, name: "Genesis", testament: "ot")
    }
    
    static var exodus: Self {
        .init(id: 2, name: "Exodus", testament: "ot")
    }
    
    static var leviticus: Self {
        .init(id: 3, name: "Leviticus", testament: "ot")
    }
}

public extension Array where Element == Book {
    static var mock: [Book] {
        [.genesis, .exodus, .leviticus]
    }
}

public struct Chapter: Equatable, Codable, Identifiable, Hashable {
    public let id: ChapterID
    
    public init(
        id: ChapterID
    ) {
        self.id = id
    }
}

public extension Chapter {
    static var mock: Self {
        .init(id: 1)
    }
}

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

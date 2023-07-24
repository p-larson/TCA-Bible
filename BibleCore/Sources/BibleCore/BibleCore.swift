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

public struct Book: Equatable, Codable, Identifiable , Hashable{
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

public struct Chapter: Equatable, Codable, Identifiable, Hashable {
    public let id: ChapterID
    
    public init(
        id: ChapterID
    ) {
        self.id = id
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

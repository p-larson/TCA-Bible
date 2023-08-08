import Foundation

public typealias TranslationID = Int

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

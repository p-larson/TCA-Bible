import Foundation
import BibleCore
import ComposableArchitecture

fileprivate let decoder = JSONDecoder()

extension BibleClient: DependencyKey {
    public static let liveValue: BibleClient = Self(
        translations: {
            let (data, _) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/translations"
                )!
            )
            return try decoder.decode([Translation].self, from: data)
        },
        translation: { id in
            let (data, _) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/translations/\(id)"
                )!
            )
            return try decoder.decode(Translation.self, from: data)
        },
        genres: {
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/genres"
                )!
            )
            
            return try decoder.decode([Genre].self, from: data)
        },
        genre: { genre in
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/genres/\(genre)"
                )!
            )
            
            return try decoder.decode(Genre.self, from: data)
        },
        books: {
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/books"
                )!
            )
            
            return try decoder.decode([Book].self, from: data)
        },
        book: { id in
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/books/\(id)"
                )!
            )
            
            return try decoder.decode(Book.self, from: data)
        },
        chapters: { book in
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    //https://bible-go-api.rkeplin.com/v1/books/1/chapters
                    string: "https://bible-go-api.rkeplin.com/v1/books/\(book)/chapters"
                )!
            )
            
            return try decoder.decode([Chapter].self, from: data)
        },
        verses: { book, chapter in
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/books/\(book)/chapters/\(chapter)"
                )!
            )
            return try decoder.decode([Verse].self, from: data)
        },
        verse: { book, chapter, verse in
            let (data, error) = try await URLSession.shared.data(
                from: URL(
                    string: "https://bible-go-api.rkeplin.com/v1/books/\(book)/chapters/\(chapter)/\(verse)"
                )!
            )
            
            return try decoder.decode(Verse.self, from: data)
        }
    )
}

//extension BibleClient {
//    public static var previewValue: BibleClient  = Self(
//        translations: <#@Sendable () async throws -> [Translation]#>,
//        translation: <#@Sendable (TranslationID) async throws -> Translation#>,
//        genres: <#@Sendable () async throws -> [Genre]#>,
//        genre: <#@Sendable (GenreID) async throws -> Genre#>,
//        books: <#@Sendable () async throws -> [Book]#>,
//        book: <#@Sendable (BookID) async throws -> Book#>,
//        chapters: <#@Sendable (BookID) async throws -> [Chapter]#>,
//        verses: <#@Sendable (BookID, ChapterID) async throws -> [Verse]#>,
//        verse: <#@Sendable (BookID, ChapterID, VerseID) async throws -> Verse#>
//    )
//}

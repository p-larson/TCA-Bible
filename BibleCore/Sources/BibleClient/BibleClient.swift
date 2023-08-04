//
//  BibleClient.swift
//  TCA-Bible
//
//  Created by Peter Larson on 7/18/23.
//

import Foundation
import BibleCore
import ComposableArchitecture

public struct BibleClient {
    public let translations: @Sendable () async throws -> [Translation]
    public let translation: @Sendable (TranslationID) async throws -> Translation
    public let genres: @Sendable () async throws -> [Genre]
    public let genre: @Sendable (GenreID) async throws -> Genre
    public let books: @Sendable () async throws -> [Book]
    public let book: @Sendable (BookID) async throws -> Book
    public let chapters: @Sendable (BookID) async throws -> [Chapter]
    public let verses: @Sendable (BookID, ChapterID) async throws -> [Verse]
    public let verse: @Sendable (BookID, ChapterID, VerseID) async throws -> Verse
}

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

enum BibleClientError: Error {
    case unknown
}

extension BibleClient {
    public static var testValue: BibleClient = Self(
        translations: { [.mock] },
        translation: { _ in .mock },
        genres: { [.mock] },
        genre: { _ in .mock },
        books: { [.genesis, .exodus, .leviticus] },
        book: { id in
            guard let book = IdentifiedArray(
                uniqueElements: [.genesis, .exodus, .leviticus] as [Book]
            )[id: id] else {
                throw BibleClientError.unknown
            }
            
            return book
        },
        chapters: { _ in [.mock] },
        verses: { _, _  in [.mock] },
        verse: { _, _, _ in .mock }
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

extension DependencyValues {
    public var bible: BibleClient {
        get {
            self[BibleClient.self]
        }
        
        set {
            self[BibleClient.self] = newValue
        }
    }
}


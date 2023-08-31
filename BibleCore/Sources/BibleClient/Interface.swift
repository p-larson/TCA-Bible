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
    public var translations: @Sendable () async throws -> [Translation]
    public var translation: @Sendable (TranslationID) async throws -> Translation
    public var genres: @Sendable () async throws -> [Genre]
    public var genre: @Sendable (GenreID) async throws -> Genre
    public var books: @Sendable () async throws -> [Book]
    public var book: @Sendable (BookID) async throws -> Book
    public var chapters: @Sendable (BookID) async throws -> [Chapter]
    public var verses: @Sendable (BookID, ChapterID) async throws -> [Verse]
    public var verse: @Sendable (BookID, ChapterID, VerseID) async throws -> Verse
}

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

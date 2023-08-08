import BibleCore
import Foundation
import ComposableArchitecture

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
            guard let book = IdentifiedArray(uniqueElements: [Book].mock)[id: id] else {
                throw BibleClientError.unknown
            }
            
            return book
        },
        chapters: { _ in [.mock] },
        verses: { _, _  in [.mock] },
        verse: { _, _, _ in .mock }
    )
}

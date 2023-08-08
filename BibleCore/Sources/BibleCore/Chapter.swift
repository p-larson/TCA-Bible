import Foundation

public typealias ChapterID = Int

public struct Chapter: Equatable, Codable, Identifiable, Hashable {
    public let id: ChapterID
    
    public init(
        id: ChapterID
    ) {
        self.id = id
    }
}

public extension Array where Element == Chapter {
    static var mock: [Chapter] {
        [.mock]
    }
}

public extension Chapter {
    static var mock: Self {
        .init(id: 1)
    }
}

import Foundation

public typealias BookID = Int

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

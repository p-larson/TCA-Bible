import Foundation

public typealias GenreID = Int

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

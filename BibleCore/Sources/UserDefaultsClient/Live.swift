import ComposableArchitecture
import Foundation

fileprivate actor UserDefaultsActor  {
    private let suite: UserDefaults
    
    func get(key: String) -> Data? {
        suite.data(forKey: key)
    }
    
    func set(_ data: Data, key: String) {
        suite.set(data, forKey: key)
    }
    
    init(
        suite: @escaping () -> (UserDefaults)
    ) {
        self.suite = suite()
    }
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: UserDefaultsClient = {
        let userDefaultsActor = UserDefaultsActor(
            suite: { UserDefaults(suiteName: "bible.larson.software")! }
        )
        
        return Self(
            get: { await userDefaultsActor.get(key: $0) },
            set: { await userDefaultsActor.set($0, key: $1) }
        )
    }()
}


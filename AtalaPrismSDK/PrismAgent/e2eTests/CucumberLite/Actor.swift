import Foundation
import XCTest

class Actor {
    var name: String
    private var context: [String: Any] = [:]
    private var abilities: [String : any Ability] = [:]
    
    init(_ name: String) {
        self.name = name
    }
    
    func initialize() async throws {
        for ability in abilities.values {
            try await ability.initialize(self)
        }
    }
    
    func tearDown() async throws {
        for ability in abilities.values {
            try await ability.teardown()
        }
    }
    
    func whoCanUse<T : Ability>(_ ability: T) -> Actor {
        abilities[String(describing: T.self)] = ability
        return self
    }
    
    func using<T : Ability>(_ ability: T.Type) throws -> T.T {
        if !abilities.contains(where: { $0.key == String(describing: ability.self) }) {
            throw ActorError.cantUseAbility(message: "Actor [\(name)] don't have the ability to use [\(ability.self)]")
        }
        return self.abilities[String(describing: ability.self)]!.ability() as! T.T
    }
    
    func remember(key: String, value: Any) {
        CucumberLogger.info("        ", "\(name) remembers [\(key)]")
        context[key] = value
    }
    
    func recall<T>(key: String) -> T {
        CucumberLogger.info("        ", "\(name) recalls [\(key)]")
        XCTAssert(context[key] != nil, "Unable to recall [\(key)] all I know is \(context.keys)")
        return context[key] as! T
    }
}

enum ActorError : Error {
    case cantUseAbility(message: String)
}

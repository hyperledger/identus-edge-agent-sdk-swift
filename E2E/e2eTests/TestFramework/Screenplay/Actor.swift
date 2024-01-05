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
            try await ability.setUp(self)
        }
    }
    
    func tearDown() async throws {
        for ability in abilities.values {
            try await ability.tearDown()
        }
    }
    
    func whoCanUse<T : Ability>(_ abilityType: T.Type) -> Actor {
        let ability = abilityType.init(self)
        abilities[String(describing: T.self)] = ability
        return self
    }
    
    private func getAbility<T: Ability>(_ ability: T.Type) -> T {
        return self.abilities[String(describing: ability.self)]! as! T
    }
    
    func using<T : Ability>(ability: T.Type,
                            action: String // = "executes an action"
    ) throws -> T.T {
        if !abilities.contains(where: { $0.key == String(describing: ability.self) }) {
            throw ActorError.CantUseAbility("Actor [\(name)] don't have the ability to use [\(ability.self)]")
        }
        let ability = getAbility(ability)
        TestConfiguration.shared().report(.ACTION, "\(name) \(action) using \(ability.abilityName)")
        return ability.instance()
    }
    
    func waitUsingAbility<T: Ability>(ability: T.Type,
                                      action: String, // = "an expectation is met",
                                      callback: (_ ability: T.T) async throws -> Bool
    ) async throws {
        let ability = getAbility(ability)
        TestConfiguration.shared().report(.ACTION, "\(name) waits until \(action) using \(ability.abilityName)")
        return try await Wait.until {
            try await callback(ability.instance())
        }
    }

    func remember(key: String, value: Any) throws {
        TestConfiguration.shared().report(.ACTION, "\(name) remembers [\(key)]")
        context[key] = value
    }
    
    func recall<T>(key: String) throws -> T {
        TestConfiguration.shared().report(.ACTION, "\(name) recalls [\(key)]")
        XCTAssert(context[key] != nil, "Unable to recall [\(key)] all I know is \(context.keys)")
        if (context[key] == nil) {
            throw ActorError.CantFindNote("\(name) don't have any note named [\(key)]")
        }
        return context[key] as! T
    }
    
    /// Here we could add attempsTo where actor can run actions, wait, etc
}

enum ActorError : Error {
    case CantUseAbility(_ message: String)
    case CantFindNote(_ message: String)
}

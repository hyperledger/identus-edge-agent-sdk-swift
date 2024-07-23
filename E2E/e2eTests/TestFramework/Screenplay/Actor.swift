import Foundation
import XCTest

class Actor {
    var name: String
    private var context: [String: Any] = [:]
    private var abilities: [String : any Ability] = [:]
    private var isInitialized: Bool = false
    
    init(_ name: String) {
        self.name = name
    }
    
    func initialize() async throws {
        if (isInitialized) {
            return
        }
        
        for ability in abilities.values {
            try await ability.setUp(self)
        }
        self.isInitialized = true
    }
    
    func tearDown() async throws {
        for ability in abilities.values {
            try await ability.tearDown()
        }
        context.removeAll()
        isInitialized = false
    }
    
    func whoCanUse<T : Ability>(_ ability: T) -> Actor {
        abilities[String(describing: T.self)] = ability
        return self
    }
    
    private func getAbility<T: Ability>(_ ability: T.Type) -> T {
        return self.abilities[String(describing: ability.self)]! as! T
    }
    
    func using<T : Ability>(ability: T.Type,
                            action: String // = "executes an action"
    ) async throws -> T {
        let dummy = T.init()
        return try await execute("\(name) \(action) using \(dummy.abilityName)") {
            if !abilities.contains(where: { $0.key == String(describing: ability.self) }) {
                throw ActorError.CantUseAbility("Actor [\(name)] don't have the ability to use [\(ability.self)]")
            }
            let ability = getAbility(ability)
            return ability
        }
    }
    
    func waitUsingAbility<T: Ability>(ability: T.Type,
                                      action: String, // = "an expectation is met",
                                      callback: (_ ability: T) async throws -> Bool
    ) async throws {
        let dummy = ability.init()
        return try await execute("\(name) waits until \(action) using \(dummy.abilityName)") {
            let ability = getAbility(ability)
            return try await Wait.until {
                try await callback(ability)
            }
        }

    }

    func remember(key: String, value: Any) async throws {
        return try await execute("\(name) remembers [\(key)]") {
            context[key] = value
        }
    }
    
    func recall<T>(key: String) async throws -> T {
        return try await execute("\(name) recalls [\(key)]") {
            if (context[key] == nil) {
                throw ActorError.CantFindNote("\(name) don't have any note named [\(key)]")
            }
            return context[key] as! T
        }
    }
    
    private func execute<T>(_ message: String, _ closure: () async throws -> T) async throws -> T {
        let actionOutcome = ActionOutcome()
        actionOutcome.action = message
        do {
            let result = try await closure()
            actionOutcome.executed = true
            try await TestConfiguration.shared().report(.ACTION, actionOutcome)
            return result
        } catch {
            actionOutcome.error = error
            try await TestConfiguration.shared().report(.ACTION, actionOutcome)
            throw error
        }
    }
    
    private func execute<T>(_ message: String, _ closure: () throws -> T) async throws -> T {
        let actionOutcome = ActionOutcome()
        actionOutcome.action = message
        do {
            let result = try closure()
            actionOutcome.executed = true
            try await TestConfiguration.shared().report(.ACTION, actionOutcome)
            return result
        } catch {
            actionOutcome.error = error
            try await TestConfiguration.shared().report(.ACTION, actionOutcome)
            throw error
        }
    }
    
    /// Here we could add attempsTo where actor can run actions, wait, etc
}

enum ActorError : Error {
    case CantUseAbility(_ message: String)
    case CantFindNote(_ message: String)
}

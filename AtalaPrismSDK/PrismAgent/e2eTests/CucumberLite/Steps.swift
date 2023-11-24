import Foundation

class Steps {
    private static var actors: [String: Actor] = [:]
    
    required init() async throws {
        Steps.actors = createActors()
        for actor in Steps.actors.values {
            try await actor.initialize()
        }
    }
    
    func teardown() async throws {
        for actor in Steps.actors.values {
            try await actor.teardown()
        }
    }
    
    func createActors() -> [String : Actor]  {
        var actors: [String: Actor] = [:]
        actors["Cloud Agent"] = Actor("Cloud Agent")
        actors["Edge Agent"] = Actor("Edge Agent").whoCan(Sdk.use())
        return actors
    }
    
    static func asInt(_ value: String) -> Int {
        return Int(value)!
    }

    static func asActor(_ name: String) -> Actor {
        return self.actors[name]!
    }
}

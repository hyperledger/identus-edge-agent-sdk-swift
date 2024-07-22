import Foundation

protocol Ability {
    var abilityName: String {get}
    var actor: Actor {get}
    var isInitialized: Bool {get}
    
    init()

    /// initialization hook, used to create the object instance for ability
    func setUp(_ actor: Actor) async throws
    
    /// teardown hook
    func tearDown() async throws
}

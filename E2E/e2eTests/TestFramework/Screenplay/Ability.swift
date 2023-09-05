import Foundation

protocol Ability {
    /// return interface for the ability
    associatedtype AbilityInstanceType
    
    var abilityName: String {get}
    var actor: Actor {get}
    
    init(_ actor: Actor)

    /// object instance returned by the ability
    func instance() -> AbilityInstanceType
    
    /// initialization hook, used to create the object instance for ability
    func setUp(_ actor: Actor) async throws
    
    /// teardown hook
    func tearDown() async throws
}

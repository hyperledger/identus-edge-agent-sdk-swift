import Foundation

protocol Ability {
    /// return interface for the ability
    associatedtype T
    
    var abilityName: String {get}
    var actor: Actor {get}
    
    init(_ actor: Actor)

    /// object instance returned by the ability
    func instance() -> T
    
    /// initialization hook, used to create the object instance for ability
    func setUp(_ actor: Actor) async throws
    
    /// teardown hook
    func tearDown() async throws
}

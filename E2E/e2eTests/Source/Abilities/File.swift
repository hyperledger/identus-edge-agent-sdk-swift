//
//  File.swift
//  
//
//  Created by io on 22/01/24.
//

import Foundation

class MyCustomAbility: Ability {

    typealias AbilityInstanceType = MyCustomAbility
    
    var abilityName: String = "my custom ability description"
    
    var actor: Actor
    
    required init(_ actor: Actor) {
        self.actor = actor
    }
  
    func instance() -> MyCustomAbility {
        return MyCustomAbility(actor)
    }
    
    func setUp(_ actor: Actor) async throws {
    }
    
    func tearDown() async throws {
    }
}

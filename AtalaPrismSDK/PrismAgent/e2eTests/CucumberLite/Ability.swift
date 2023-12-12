//
//  File.swift
//  
//
//  Created by io on 22/11/23.
//

import Foundation

protocol Ability {
    /// return interface for the ability
    associatedtype T

    /// object instance returned by the ability
    func ability() -> T
    
    /// initialization hook, used to create the object instance for ability
    func setUp(_ actor: Actor) async throws
    
    /// teardown hook
    func tearDown() async throws
}

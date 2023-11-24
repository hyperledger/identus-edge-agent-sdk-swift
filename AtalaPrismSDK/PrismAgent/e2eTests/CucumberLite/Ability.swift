//
//  File.swift
//  
//
//  Created by io on 22/11/23.
//

import Foundation

protocol Ability {
    func initialize() async throws
    func teardown() async throws
}

//
//  User.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/29/25.
//

import Foundation

struct User: Codable {
    var id: Int64?
    var name: String
    var email: String
    var createdAt: Date
    var updatedAt: Date
}

//
//  LoginRequest.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/29/25.
//

import Foundation

struct LoginRequest: Codable {
    var email: String
    var password: String
}

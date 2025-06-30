//
//  SignupRequest.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/29/25.
//

import Foundation

struct SignupRequest: Codable {
    var name: String
    var email: String
    var password: String
}

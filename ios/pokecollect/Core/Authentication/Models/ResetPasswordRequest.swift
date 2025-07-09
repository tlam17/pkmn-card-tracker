//
//  ResetPasswordRequest.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/9/25.
//

import Foundation

struct ResetPasswordRequest: Codable {
    let email: String
    let code: String
    let newPassword: String
}

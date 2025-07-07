//
//  ForgotPasswordView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/7/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    // MARK: - Navigation Callback
    let onForgotPasswordTapped: () -> Void
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - Convenience Initializer for Previews
extension ForgotPasswordView {
    init() {
        self.onForgotPasswordTapped = {}
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}

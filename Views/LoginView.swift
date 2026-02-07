//
//  LoginView.swift
//  FireBaseExample
//
//  Created by user285578 on 10/21/25.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authManager: AuthManager
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            TextField("Enter Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.none)
            
            SecureField("Enter Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Button("Login") {
                authManager.login(email: email, password: password) { result in
                    switch result {
                    case .success:
                        print("Login Successful")
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
            
            NavigationLink(destination: RegisterView()) {
                Text("Register here!")
            }
        }.padding()
    }
}

#Preview {
    LoginView()
}

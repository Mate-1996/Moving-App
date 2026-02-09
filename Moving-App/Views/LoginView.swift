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
                Task {
                        await authManager.signIn(email: email, password: password)

                        if let msg = authManager.authError {
                            self.errorMessage = msg
                        } else {
                            print("Login Successful")
                        }
                    }            }
            
            NavigationLink(destination: RegisterView()) {
                Text("Register here!")
            }
        }.padding()
    }
}

#Preview {
    LoginView()
}

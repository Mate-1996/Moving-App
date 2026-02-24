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
            Text("Login")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.goodPurple)
                .padding(.bottom, 50)
            
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
            
            Button(action: loginUser) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.goodPurple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            NavigationLink(destination: RegisterView()) {
                Text("Back To Register")
                    .padding()
            }
        }.padding()
    }
    
    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }
        
        Task {
                await authManager.signIn(email: email, password: password)

                if let msg = authManager.authError {
                    self.errorMessage = msg
                } else {
                    print("Login Successful")
                }
            }

    }
}



#Preview {
    LoginView()
}

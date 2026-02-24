//
//  RegisterView.swift
//  FireBaseExample
//
//  Created by user285578 on 10/21/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedRole: UserRole = .regular

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            
            TextField("Enter Display Name", text: $displayName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
            
            // Email
            TextField("Enter Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
            
            // Password
            SecureField("Enter Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            // Register Button
            Button(action: registerUser) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text("Already have an account?")
                .font(.footnote)
                .padding(.top, 10)
                .foregroundStyle(.gray)

            // Navigation Link
            NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .frame(maxWidth: 90)
                        .padding(5)
                        .background(Color.goodPurple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
            }
        }
        .padding()
    }

    private func registerUser() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }

        Task {
            await authManager.signUp(
                email: email,
                password: password,
                displayName: displayName,
                role: selectedRole
            )

            if let msg = authManager.authError {
                errorMessage = msg
            } else {
                print("✅ Registration successful — Firestore user created.")
                errorMessage = nil
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}

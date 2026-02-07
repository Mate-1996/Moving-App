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

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            
            // Display Name
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

            // Navigation Link
            NavigationLink(destination: LoginView()) {
                Text("Already have an account? Login here.")
                    .font(.footnote)
            }
        }
        .padding()
    }

    private func registerUser() {
        // Simple validation
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            self.errorMessage = "Please fill out all fields."
            return
        }

        // Call new signUp function
        authManager.signUp(email: email, password: password, displayName: displayName) { result in
            switch result {
            case .success:
                print("✅ Registration successful — Firestore user created.")
                errorMessage = nil
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}

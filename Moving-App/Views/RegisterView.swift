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
            
            TextField("Enter Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
            

            SecureField("Enter Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            

            Picker("Role: ", selection: $selectedRole) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Text(role.rawValue).tag(role)
                }
            }
            .pickerStyle(.menu)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            Button(action: registerUser) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            NavigationLink(destination: LoginView()) {
                Text("Already have an account? Login here.")
                    .font(.footnote)
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
                print("registration success")
                errorMessage = nil
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}

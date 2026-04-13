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
    @State private var displayName  = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("goodPurple"), Color("goodPurple").opacity(0.6), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {

                    VStack(spacing: 8) {
                        Text("Movex")
                            .font(.system(size: 38, weight: .black))
                            .foregroundColor(.white)
                        Text("Create your account")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 60)

                    VStack(spacing: 14) {
                        TextField("Display Name", text: $displayName)
                            .autocapitalization(.words)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)

                    if let err = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(err).font(.system(size: 13))
                        }
                        .foregroundColor(.red.opacity(0.9))
                        .padding(.horizontal, 28)
                        .multilineTextAlignment(.leading)
                    }

                    Button(action: register) {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("goodPurple"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)

                    HStack(spacing: 6) {
                        NavigationLink(destination: LoginView()) {
                            Text("Sign In")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func register() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill out all fields."; return
        }
        isLoading = true
        errorMessage = nil
        Task {
            await authManager.signUp(email: email, password: password,
                                     displayName: displayName, role: .regular)
            if let msg = authManager.authError { errorMessage = msg }
            isLoading = false
        }
    }
}


#Preview {
    RegisterView().environmentObject(AuthManager())
}

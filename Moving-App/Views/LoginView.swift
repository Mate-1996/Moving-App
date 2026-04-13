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
    @State private var errorMessage: String?
    @State private var isLoading = false

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode

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
                        Text("Welcome back")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 80)

                    VStack(spacing: 14) {
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
                    }

                    Button(action: login) {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
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
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("Register")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(nil)
        .navigationBarHidden(true)
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill out all fields"; return
        }
        isLoading = true
        errorMessage = nil
        Task {
            await authManager.signIn(email: email, password: password)
            if let msg = authManager.authError { errorMessage = msg }
            isLoading = false
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthManager())
}

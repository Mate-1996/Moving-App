//
//  RegisterView.swift
//  FireBaseExample
//
//  Created by user285578 on 10/21/25.
//

import SwiftUI

struct LiquidGlassFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.20),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.30), lineWidth: 1)
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 15, design: .rounded))
            .tint(.white)
    }
}

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?

    @EnvironmentObject var authManager: AuthManager
    @State private var selectedRole: UserRole = .regular

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Movex")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                Text("Create Account")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.bottom, 12)

                TextField("Display Name", text: $displayName)
                    .autocapitalization(.words)
                    .autocorrectionDisabled(true)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)

                SecureField("Password", text: $password)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white.opacity(0.85))
                        .font(.system(size: 13, design: .rounded))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

               
                Button(action: registerUser) {
                    Text("Register")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.ultraThinMaterial)

                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.28),
                                                Color.white.opacity(0.06)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.40), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
                .padding(.top, 4)

                Text("Already have an account?")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 12)

                NavigationLink(destination: LoginView()) {
                    Text("Sign In")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 9)
                        .background {
                            ZStack {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.30), lineWidth: 1)
                            }
                        }
                }
            }
            .padding(.horizontal, 28)
        }
        .preferredColorScheme(.dark)
    }

    private func registerUser() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            withAnimation { errorMessage = "Please fill out all fields." }
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
                withAnimation { errorMessage = msg }
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

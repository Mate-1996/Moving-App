//
//  AddMoversView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-09.
//

import SwiftUI

struct AddMoversView: View {
    @State private var email: String = ""
    @State private var displayName: String = ""
    @State private var password: String = ""
    @State private var role: UserRole = .mover
    @State private var errorMessage: String?
    @State private var showSuccessToast = false
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text("Add Mover")
                    .font(.largeTitle)
                    .padding(.bottom, 40)
                    .bold()

                Text("Email:")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.gray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Enter Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .padding(.bottom)

                Text("Display Name:")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.gray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Enter Display Name", text: $displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .padding(.bottom)

                Text("Password:")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.gray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                SecureField("Enter Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Button(action: createMoverAccount) {
                    Text("Create Mover Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .bold()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)

            if showSuccessToast {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Mover account created")
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(radius: 6)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: showSuccessToast)
            }
        }
        .navigationTitle("Add Mover")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createMoverAccount() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }

        errorMessage = nil

        Task {
            await authManager.signUp(
                email: email,
                password: password,
                displayName: displayName,
                role: .mover
            )

            if let msg = authManager.authError {
                errorMessage = msg
            } else {
                
                email = ""
                displayName = ""
                password = ""

                withAnimation {
                    showSuccessToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showSuccessToast = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddMoversView()
            .environmentObject(AuthManager())
    }
}

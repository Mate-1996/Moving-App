//
//  AddAdminView.swift
//  Moving-App
//
//  Created by user285578 on 3/7/26.
//

import SwiftUI

struct AddAdminView: View {
    @State private var email: String = ""
    @State private var displayName: String = ""
    @State private var password: String = ""
    @State private var role: UserRole = .admin
    @State private var errorMessage: String?
    @State private var showSuccessToast = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text("Add Admin")
                    .font(.largeTitle)
                    .padding(.bottom, 40)
                    .bold()
                
                Text("Email:")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.gray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.none)
                    .padding(.bottom)
                
                Text("Display Name:")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.gray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter Display Name", text: $displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.none)
                    .padding(.bottom)
                
                Text("Password:")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.gray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                SecureField("Enter Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
                
                Spacer()
                
                Button(action: signUpUser) {
                    Text("Create Admin")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.goodPurple)
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
                        
                        Text("Admin account created")
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
    }
    
    private func signUpUser() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }
        
        Task {
            await authManager.signUp(email: email, password: password, displayName: displayName, role: role)
            if let msg = authManager.authError {
                self.errorMessage = msg
            } else { //shows a lil toast
                errorMessage = nil
                withAnimation {
                    showSuccessToast = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { //hides toast
                    withAnimation{
                        showSuccessToast = false
                    }
                }
            }
        }
    }
}

#Preview {
    AddAdminView()
}

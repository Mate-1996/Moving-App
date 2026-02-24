//
//  HomeView.swift
//  FireBaseExample
//
//  Created by user285578 on 10/21/25.
//

import SwiftUI
import FirebaseAuth

struct UserView: View {
    
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        VStack {
            Text("Welcome \(authManager.user?.displayName ?? "User")")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
            
            Text("Your thing is: \(authManager.user?.role.rawValue ?? "Unknown")")
            
            Button {
                authManager.signOut()
            } label: {
                Text("Logout")
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color("goodPurple"))
                    .cornerRadius(10)
                    
            }
        }
    }
}

#Preview {
    UserView()
}

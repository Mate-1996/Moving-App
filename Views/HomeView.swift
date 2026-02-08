//
//  HomeView.swift
//  FireBaseExample
//
//  Created by user285578 on 10/21/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        VStack {
                Text("Welcome \(authManager.user?.displayName ?? "User")")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
            
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
    HomeView()
}

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
                    
                    VStack(spacing: 20) {
                        
                       
                        
                        
                        NavigationLink(destination: MyMoveRequestsView()) {
                            ActionCard(
                                icon: "list.bullet.clipboard.fill",title: "My Move Requests",color: .orange)
                        }
                        
                        
                        NavigationLink(destination: ChatView()) {
                            ActionCard(icon: "message.fill",title: "Messages",color: .black)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }


struct ActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct MyMoveRequestsView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("My Move Requests")
                .foregroundColor(.black)
        }
        .navigationTitle("Move Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("Messages")
                .foregroundColor(.black)
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UserView()
}

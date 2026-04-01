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

            Text("Your user role is: \(authManager.user?.role.rawValue ?? "Unknown")")

            VStack(spacing: 20) {
                NavigationLink(destination: AddressEntryView()) {
                    ActionCard(icon: "location.fill", title: "Enter Address", color: .goodPurple)
                }

                NavigationLink(destination: OrganizeMoveView()) {
                    ActionCard(icon: "list.bullet.clipboard.fill", title: "Organize Moves", color: .orange)
                }

                NavigationLink(destination: MoveRequestsView()) {
                    ActionCard(icon: "house.fill", title: "My Move Requests", color: .orange)
                }

                NavigationLink(destination: ChatListView()) {
                    ActionCard(icon: "message.fill", title: "Messages", color: .black)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            Button(action: { authManager.signOut() }) {
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

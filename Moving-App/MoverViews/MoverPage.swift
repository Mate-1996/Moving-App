//
//  AddMoversView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-09.
//

import SwiftUI

struct MoverPage: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Hello, \(authManager.user?.displayName ?? "Mover")")
                            .font(.largeTitle)
                            .bold()

                        Text("Your assigned moves and messages")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)

                    VStack(spacing: 16) {
                        NavigationLink(destination: ChatListView()) {
                            MoverActionCard(
                                systemIcon: "bubble.left.and.bubble.right.fill",
                                title: "Messages",
                                subtitle: "Chat with clients and admin"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Button(action: { authManager.signOut() }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Mover Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MoverActionCard: View {
    let systemIcon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemIcon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color("goodPurple"))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(14)
    }
}

#Preview {
    MoverPage()
        .environmentObject(AuthManager())
}

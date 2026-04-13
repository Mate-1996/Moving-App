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
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello,")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(authManager.user?.displayName ?? "Mover")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Your assignments and messages")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                        VStack(spacing: 14) {
                            MoverNavCard(
                                icon: "bubble.left.and.bubble.right.fill",
                                title: "Messages",
                                subtitle: "Chat with clients and admin",
                                color: Color("goodPurple"),
                                destination: AnyView(ChatListView())
                            )
                            MoverNavCard(
                                icon: "shippingbox.fill",
                                title: "Assigned Move",
                                subtitle: "View your current assignment",
                                color: .orange,
                                destination: AnyView(MoverAssignedMoveView())
                            )
                            MoverNavCard(
                                icon: "calendar.badge.clock",
                                title: "Time Off",
                                subtitle: "Request and view your vacation days",
                                color: .teal,
                                destination: AnyView(TimeOffView())
                            )
                        }
                        .padding(.horizontal, 20)

                        Button(action: { authManager.signOut() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout").fontWeight(.semibold)
                            }
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4), lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MoverNavCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MoverPage().environmentObject(AuthManager())
}

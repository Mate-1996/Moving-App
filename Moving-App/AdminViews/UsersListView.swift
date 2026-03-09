//
//  UsersListView.swift
//  Moving-App
//
//  Created by user285578 on 3/7/26.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject var authManager: AuthManager

        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("All Users")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    if authManager.isLoading {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView("Loading users...")
                            Spacer()
                        }
                        Spacer()
                    } else if let error = authManager.allUsersError {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                        Spacer()
                    } else if authManager.allUsers.isEmpty {
                        Spacer()
                        Text("No users found.")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(authManager.allUsers) { user in
                                    NavigationLink(destination: UsersInfoView(user: user)) {
                                        UserRowCard(user: user)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await authManager.fetchAllUsers()
            }
            .refreshable {
                await authManager.fetchAllUsers()
            }
        }
}

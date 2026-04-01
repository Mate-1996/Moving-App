//
//  UsersListView.swift
//  Moving-App
//
//  Created by user285578 on 3/7/26.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var userToDelete: UserModel? = nil
    @State private var showDeleteConfirmation = false
    @State private var selectedUser: UserModel? = nil

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
                        ProgressView("Loading users")
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
                    List {
                        ForEach(authManager.allUsers) { user in
                            UserRowCard(user: user)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedUser = user
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        userToDelete = user
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedUser) { user in
            UsersInfoView(user: user)
        }
        .task {
            await authManager.fetchAllUsers()
        }
        .refreshable {
            await authManager.fetchAllUsers()
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation, presenting: userToDelete) { user in
            Button("Delete", role: .destructive) {
                Task {
                    await authManager.deleteUser(user)
                }
            }
            Button("Cancel", role: .cancel) {
                userToDelete = nil
            }
        } message: { user in
            Text("Are you sure you want to delete \(user.displayName.isEmpty ? "this user" : user.displayName) account? This action cannot be undone.")
        }
    }
}

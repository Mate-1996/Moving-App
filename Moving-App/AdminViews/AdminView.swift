import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 5){
                    // Header
                    VStack(spacing: 10) {
                        Text("Hello, \(authManager.user?.displayName ?? "User")")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Manage users, movers, and move requests")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Admin tools
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: UsersListView()) {
                            AdminActionCard(
                                systemIcon: "person.3.fill",
                                title: "See All Users",
                                subtitle: "View and manage all registered users"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: AllMovesView()) {
                            AdminActionCard(
                                systemIcon: "truck.box.fill",
                                title: "See All Current Moves",
                                subtitle: "View and manage all move requests"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: AddMoversView()) {
                            AdminActionCard(
                                systemIcon: "person.badge.plus.fill",
                                title: "Add Mover Account",
                                subtitle: "Create a new mover account for the platform"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: AddAdminView()) {
                            AdminActionCard(
                                systemIcon: "person.crop.circle.badge.plus",
                                title: "Add Another Admin",
                                subtitle: "Grant admin privileges to a new account"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        authManager.signOut()
                    }) {
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
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    AdminView()
}

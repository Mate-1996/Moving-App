import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                
                // Header
                VStack(spacing: 10) {
                    Text("Hello, Admin!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Manage users, movers, and move requests")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // Admin tools
                ScrollView {
                    VStack(spacing: 16) {
                        
                        AdminActionCard(
                            systemIcon: "person.3.fill",
                            title: "See All Users",
                            subtitle: "View and manage all registered users"
                        )
                        
                        AdminActionCard(
                            systemIcon: "person.badge.plus.fill",
                            title: "Add Mover Account",
                            subtitle: "Create a new mover account for the platform"
                        )
                        
                        AdminActionCard(
                            systemIcon: "person.crop.circle.badge.plus",
                            title: "Add Another Admin",
                            subtitle: "Grant admin privileges to a new account"
                        )
                        
                        AdminActionCard(
                            systemIcon: "truck.box.fill",
                            title: "See All Current Moves",
                            subtitle: "View and manage all move requests"
                        )
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
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
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    AdminView()
}

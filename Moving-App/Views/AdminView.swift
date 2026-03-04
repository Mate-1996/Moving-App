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
                            icon: "person.3.fill",
                            title: "See All Users",
                            description: "View and manage all registered users"
                        )
                        
                        AdminActionCard(
                            icon: "person.badge.plus.fill",
                            title: "Add Mover Account",
                            description: "Create a new mover account for the platform"
                        )
                        
                        AdminActionCard(
                            icon: "person.crop.circle.badge.plus",
                            title: "Add Another Admin",
                            description: "Grant admin privileges to a new account"
                        )
                        
                        AdminActionCard(
                            icon: "truck.box.fill",
                            title: "See All Current Moves",
                            description: "View and manage all move requests"
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

struct AdminActionCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        Button(action: {
            // Navigation handled later
        }) {
            HStack(spacing: 16) {
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color("goodPurple"))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(description)
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
}

#Preview {
    AdminView()
}

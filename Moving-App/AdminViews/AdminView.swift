
import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.user?.displayName ?? "Admin")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        VStack(spacing: 14) {
                            AdminNavCard(icon: "person.3.fill",
                                         title: "All Users",
                                         subtitle: "Manage Accounts",
                                         color: Color("goodPurple"),
                                         destination: AnyView(UsersListView()))

                            AdminNavCard(icon: "truck.box.fill",
                                         title: "Move Requests",
                                         subtitle: "Review and assign moves",
                                         color: .orange,
                                         destination: AnyView(AllMovesView()))

                            AdminNavCard(icon: "calendar.badge.clock",
                                         title: "Mover Time Off",
                                         subtitle: "Approve or reject vacation requests",
                                         color: .teal,
                                         destination: AnyView(AdminTimeOffView()))

                            AdminNavCard(icon: "person.badge.plus.fill",
                                         title: "Add Mover",
                                         subtitle: "Create a mover account",
                                         color: Color(.systemIndigo),
                                         destination: AnyView(AddMoversView()))

                            AdminNavCard(icon: "person.crop.circle.badge.plus",
                                         title: "Add Admin",
                                         subtitle: "Grant admin privileges",
                                         color: .black,
                                         destination: AnyView(AddAdminView()))

                            AdminNavCard(icon: "bubble.left.and.bubble.right.fill",
                                         title: "Messages",
                                         subtitle: "View all group chats",
                                         color: Color(.systemGray),
                                         destination: AnyView(ChatListView()))
                        }
                        .padding(.horizontal, 20)

                        Button(action: { authManager.signOut() }) {
                            HStack(spacing: 8) {
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
        }
    }
}

private struct AdminNavCard: View {
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
                        .font(.system(size: 21))
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

struct AdminActionCard: View {
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
                Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                Text(subtitle).font(.system(size: 13)).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

#Preview {
    AdminView().environmentObject(AuthManager())
}

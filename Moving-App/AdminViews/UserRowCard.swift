//
//  UserRowCard.swift
//  Moving-App
//
//  Created by user285578 on 3/7/26.
//

import SwiftUI

struct UserRowCard: View {
    let user: UserModel
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName(for: user.role))
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(roleColor(for: user.role))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName.isEmpty ? "No Name" : user.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(user.email)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text(user.role.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                    
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(user.isActive ? .green : .red)
                    
                    Text(user.isActive ? "Active" : "Inactive")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(14)
    }
    
    private func iconName(for role: UserRole) -> String {
            switch role {
            case .regular:
                return "person.fill"
            case .mover:
                return "figure.walk"
            case .admin:
                return "person.crop.circle.badge.checkmark"
            }
        }

        private func roleColor(for role: UserRole) -> Color {
            switch role {
            case .regular:
                return Color("goodPurple")
            case .mover:
                return .orange
            case .admin:
                return .black
            }
        }
}

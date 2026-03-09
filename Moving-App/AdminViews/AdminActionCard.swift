//
//  AdminActionCard.swift
//  Moving-App
//
//  Created by user285578 on 3/7/26.
//

import SwiftUI

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
                .background(Color.gray.opacity(0.2))
                .cornerRadius(14)
    }
}

#Preview {
    AdminActionCard(
        systemIcon: "person.3.fill", title: "See All Users", subtitle: "view and manage all users."
    )
}

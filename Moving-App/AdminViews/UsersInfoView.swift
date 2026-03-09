//
//  UsersInfoView.swift
//  Moving-App
//
//  Created by user285578 on 3/7/26.
//

import SwiftUI

struct UsersInfoView: View {
    let user: UserModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(user.displayName.isEmpty ? "No Name" : user.displayName)
                .font(.largeTitle)
                .bold()
            
            Text(user.email)
                .foregroundColor(.gray)
            
            Text("Role: \(user.role.rawValue.capitalized)")
            Text("Status: \(user.isActive ? "Active" : "Inactive")")
            
            Spacer()
        }
        .padding()
        .navigationTitle("User Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}


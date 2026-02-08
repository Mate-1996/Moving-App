//
//  User.swift
//  MovingAppProject
//
//  Created by user285578 on 2/6/26.
//

import Foundation
import FirebaseFirestore

struct UserModel: Codable, Identifiable {
    var email: String
    var displayName: String
    var isActive: Bool
    @DocumentID var id: String?
    var role: UserRole
}

enum UserRole: String, Codable, CaseIterable {
    case regular
    case mover
    case admin
}

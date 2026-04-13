//
//  User.swift
//  MovingAppProject
//
//  Created by user285578 on 2/6/26.
//

import Foundation
import FirebaseFirestore

struct UserModel: Codable, Identifiable, Hashable {
    var email: String
    var displayName: String
    @DocumentID var id: String?
    var role: UserRole
    var address: Address?
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Address: Codable {
    var addressLine: String
    var city: String
    var province: String
    var postalCode: String
}

enum UserRole: String, Codable, CaseIterable {
    case regular = "Regular"
    case mover = "Mover"
    case admin = "Admin"
}

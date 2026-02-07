//
//  User.swift
//  MovingAppProject
//
//  Created by user285578 on 2/6/26.
//

import Foundation
import FirebaseFirestore

struct UserModel: Encodable, Decodable {
    var email: String
    var displayName: String
    var isActive: Bool
    @DocumentID var id: String?
}

enum userType {
    case User
    case Mover
    case Admin
}

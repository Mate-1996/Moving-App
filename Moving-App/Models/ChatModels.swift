//
//  ChatModels.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import Foundation
import FirebaseFirestore
 
struct Chat: Codable, Identifiable {
    @DocumentID var id: String?
    var requestId: String
    var participantIds: [String]
    var lastMessage: String?
    var lastMessageAt: Date?
    @ServerTimestamp var createdAt: Date?
}
 
struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var senderId: String
    var senderName: String
    var text: String
    @ServerTimestamp var sentAt: Date?
}
 

//
//  ChatService.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    private let db = Firestore.firestore()

    func createChat(requestId: String, userId: String,
                    moverIds: [String], adminId: String) async throws -> String {
        let existing = try await db.collection("chats")
            .whereField("requestId", isEqualTo: requestId)
            .getDocuments()

        if let first = existing.documents.first {
            let chatId = first.documentID
            try await db.collection("chats").document(chatId).updateData([
                "participantIds": FieldValue.arrayUnion(moverIds)
            ])
            return chatId
        }

        let participantIds = [userId, adminId] + moverIds
        let chat = Chat(
            requestId:      requestId,
            participantIds: participantIds,
            lastMessage:    "Chat started",
            lastMessageAt:  Date()
        )
        let ref = try db.collection("chats").addDocument(from: chat)
        return ref.documentID
    }

    func fetchChats(for userId: String) async throws -> [Chat] {
        let snapshot = try await db.collection("chats")
            .whereField("participantIds", arrayContains: userId)
            .getDocuments()

        return try snapshot.documents
            .map { try $0.data(as: Chat.self) }
            .sorted { ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast) }
    }

    func sendMessage(chatId: String, text: String, senderName: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message = Message(senderId: uid, senderName: senderName, text: text)
        try db.collection("chats").document(chatId)
            .collection("messages").addDocument(from: message)
        try await db.collection("chats").document(chatId).updateData([
            "lastMessage":   text,
            "lastMessageAt": Date()
        ])
    }

    func listenToMessages(chatId: String, onChange: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "sentAt", descending: false)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let messages = docs.compactMap { try? $0.data(as: Message.self) }
                onChange(messages)
            }
    }

    func deleteChat(chatId: String) async throws {
        let messages = try await db.collection("chats").document(chatId)
            .collection("messages").getDocuments()
        for doc in messages.documents {
            try await doc.reference.delete()
        }
        try await db.collection("chats").document(chatId).delete()
    }
}

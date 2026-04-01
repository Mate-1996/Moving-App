//
//  MoveRequestService.swift
//  Moving-App
//
//  Created by user285578 on 2/25/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MoveRequestService {
    private let db = Firestore.firestore()
    private let chatService = ChatService()


    func createMoveRequest(
        pickupAddress: Address,
        destinationAddress: Address,
        numberOfRooms: Int,
        numberOfFragileItems: Int,
        floorLevel: Int,
        hasElevator: Bool,
        specialInstructions: String?
    ) async throws -> String {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "MoveRequest", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No logged in user"])
        }

        let request = MoveRequest(
            userId: uid,
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress,
            numberOfRooms: numberOfRooms,
            numberOfFragileItems: numberOfFragileItems,
            floorLevel: floorLevel,
            hasElevator: hasElevator,
            specialInstructions: specialInstructions?.isEmpty == true ? nil : specialInstructions,
            status: .pending,
            createdAt: nil
        )

        let ref = try db.collection("moveRequests").addDocument(from: request)
        return ref.documentID
    }


    func acceptRequest(id: String) async throws {
        try await db.collection("moveRequests").document(id)
            .updateData(["status": MoveRequestStatus.accepted.rawValue])
    }


    func assignMover(requestId: String, moverId: String, adminId: String) async throws {
        let ref = db.collection("moveRequests").document(requestId)
        try await ref.updateData(["moverId": moverId])

        let doc = try await ref.getDocument()
        guard let request = try? doc.data(as: MoveRequest.self) else { return }

        if request.status == .accepted {
            try await chatService.createChat(
                requestId: requestId,
                userId: request.userId,
                moverId: moverId,
                adminId: adminId
            )
        }
    }
}

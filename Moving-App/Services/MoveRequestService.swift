//
//  MoveRequestService.swift
//  Moving-App
//
//  Created by user285578 on 2/25/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class MoveRequestService {
    private let db = Firestore.firestore()

    func createMoveRequest(
        pickupAddress: Address,
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
}

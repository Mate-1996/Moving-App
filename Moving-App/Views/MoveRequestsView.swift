//
//  MoveRequestsView.swift
//  Moving-App
//
//  Created by user285578 on 2/25/26.
//

import SwiftUI
import FirebaseFirestore



enum MoveRequestStatus: String, Codable {
    case pending
    case accepted
    case completed
}

struct MoveRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String

    var pickupAddress: Address

    var numberOfRooms: Int
    var numberOfFragileItems: Int
    var floorLevel: Int
    var hasElevator: Bool
    var specialInstructions: String?
    var moverId: String?

    var status: MoveRequestStatus
    @ServerTimestamp var createdAt: Date?
}


struct MoveRequestsView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(alignment: .center) {
            Text("Move Requests")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)

            if authManager.isLoading {
                ProgressView()
                    .padding()
            }

            if let err = authManager.moveRequestsError {
                Text(err)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            if authManager.myMoveRequests.isEmpty && !authManager.isLoading {
                Text("No move requests yet.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                List(authManager.myMoveRequests) { req in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(req.pickupAddress.addressLine)
                            .font(.headline)

                        Text("\(req.pickupAddress.city), \(req.pickupAddress.province) \(req.pickupAddress.postalCode)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            Text("Status: \(req.status.rawValue.capitalized)")
                                .font(.subheadline)
                            Spacer()
                            Text(req.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Text("Rooms: \(req.numberOfRooms) • Fragile: \(req.numberOfFragileItems) • Floor: \(req.floorLevel) • Elevator: \(req.hasElevator ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if let notes = req.specialInstructions, !notes.isEmpty {
                            Text("Notes: \(notes)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .task {
            await authManager.fetchMoveRequests()
        }
        .refreshable {
            await authManager.fetchMoveRequests()
        }
    }
}

#Preview {
    MoveRequestsView()
}

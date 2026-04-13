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
    var destinationAddress: Address?
    var numberOfRooms: Int
    var numberOfFragileItems: Int
    var floorLevel: Int
    var hasElevator: Bool
    var specialInstructions: String?
    var moverIds: [String]?
    var status: MoveRequestStatus
    @ServerTimestamp var createdAt: Date?

    init(id: String? = nil, userId: String, pickupAddress: Address,
         destinationAddress: Address? = nil, numberOfRooms: Int,
         numberOfFragileItems: Int, floorLevel: Int, hasElevator: Bool,
         specialInstructions: String?, moverIds: [String]? = nil,
         status: MoveRequestStatus, createdAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.numberOfRooms = numberOfRooms
        self.numberOfFragileItems = numberOfFragileItems
        self.floorLevel = floorLevel
        self.hasElevator = hasElevator
        self.specialInstructions  = specialInstructions
        self.moverIds = moverIds
        self.status = status
        self.createdAt = createdAt
    }
}

struct MoveRequestsView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var requestToCancel: MoveRequest? = nil
    @State private var showCancelAlert  = false
    @State private var cancelError:     String? = nil

    private let svc = MoveRequestService()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                if authManager.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading…"); Spacer() }
                    Spacer()

                } else if let err = authManager.moveRequestsError {
                    Spacer()
                    Text(err).foregroundColor(.red).padding()
                    Spacer()

                } else if authManager.myMoveRequests.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("No move requests yet")
                            .font(.headline).foregroundColor(.secondary)
                        Text("Submit a move request from the Organize Move section.")
                            .font(.caption).foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(authManager.myMoveRequests) { req in
                                UserMoveRequestCard(
                                    request: req,
                                    onCancel: {
                                        requestToCancel = req
                                        showCancelAlert = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }

                if let err = cancelError {
                    Text(err)
                        .font(.caption).foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("My Requests")
        .navigationBarTitleDisplayMode(.large)
        .task { await authManager.fetchMoveRequests() }
        .refreshable { await authManager.fetchMoveRequests() }
        .alert("Cancel Request", isPresented: $showCancelAlert, presenting: requestToCancel) { req in
            Button("Yes, Cancel Request", role: .destructive) {
                Task { await cancelRequest(req) }
            }
            Button("Keep It", role: .cancel) {
                requestToCancel = nil
            }
        } message: { req in
            Text("Are you sure you want to cancel your move request from \(req.pickupAddress.addressLine)? This cannot be undone.")
        }
    }

    private func cancelRequest(_ req: MoveRequest) async {
        guard let id = req.id else { return }
        cancelError = nil
        do {
            try await svc.cancelRequest(id: id)
            authManager.myMoveRequests.removeAll { $0.id == id }
        } catch {
            cancelError = error.localizedDescription
        }
    }
}


private struct UserMoveRequestCard: View {
    let request:  MoveRequest
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                StatusBadge(status: request.status)
                Spacer()
                if let date = request.createdAt {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption).foregroundColor(.secondary)
                }
            }

            Divider()

            VStack(spacing: 10) {
                AddressRow(icon: "location.fill", color: Color("goodPurple"),
                           label: "From", address: request.pickupAddress.addressLine,
                           detail: "\(request.pickupAddress.city), \(request.pickupAddress.province)")

                if let dest = request.destinationAddress {
                    AddressRow(icon: "mappin.and.ellipse", color: .orange,
                               label: "To", address: dest.addressLine,
                               detail: "\(dest.city), \(dest.province)")
                }
            }

            Divider()

            HStack(spacing: 0) {
                StatPill(icon: "bed.double.fill",  value: "\(request.numberOfRooms)", label: "rooms")
                Spacer()
                StatPill(icon: "shippingbox", value: "\(request.numberOfFragileItems)", label: "fragile")
                Spacer()
                StatPill(icon: "building.2", value: "Fl \(request.floorLevel)", label: "floor")
                Spacer()
                StatPill(icon: request.hasElevator ? "elevator" : "figure.stairs",
                         value: request.hasElevator ? "Yes" : "No", label: "elevator")
            }

            if let notes = request.specialInstructions, !notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text").font(.caption).foregroundColor(.secondary)
                    Text(notes).font(.caption).foregroundColor(.secondary).lineLimit(2)
                }
                .padding(10).background(Color(.systemGray6)).cornerRadius(10)
            }

            if request.status == .pending {
                Button(action: onCancel) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel Request")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }
}


private struct AddressRow: View {
    let icon: String; let color: Color
    let label: String; let address: String; let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14)).foregroundColor(color).frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(address)
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.primary).lineLimit(1)
                Text(detail)
                    .font(.system(size: 12)).foregroundColor(.secondary)
            }
        }
    }
}

private struct StatPill: View {
    let icon: String; let value: String; let label: String
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(.secondary)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundColor(.primary)
            Text(label).font(.system(size: 10)).foregroundColor(.secondary)
        }
    }
}

#Preview {
    MoveRequestsView()
}

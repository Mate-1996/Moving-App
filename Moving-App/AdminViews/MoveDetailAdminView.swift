//
//  MoveDetailAdminView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-04-13.
//

import Foundation
import SwiftUI
import CoreData

struct MoveDetailAdminView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var request: MoveRequest
    @State private var showMoverPicker = false
    @State private var isWorking = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    private let svc = MoveRequestService()
    
    init(request: MoveRequest) {
        _request = State(initialValue: request)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        StatusBadge(status: request.status)
                        Spacer()
                        if let date = request.createdAt {
                            Text(date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundColor(.gray)
                        }
                    }
                    
                    DetailSection(title: "Pickup Address") {
                        Text(request.pickupAddress.addressLine).font(.body)
                        Text("\(request.pickupAddress.city), \(request.pickupAddress.province) \(request.pickupAddress.postalCode)")
                            .font(.subheadline).foregroundColor(.gray)
                    }
                    
                    DetailSection(title: "Move Details") {
                        if let dest = request.destinationAddress {
                            DetailRow(label: "Destination", value: dest.addressLine)
                            Divider()
                        }
                        DetailRow(label: "Rooms", value: "\(request.numberOfRooms)")
                        Divider()
                        DetailRow(label: "Fragile items", value: "\(request.numberOfFragileItems)")
                        Divider()
                        DetailRow(label: "Floor level", value: "\(request.floorLevel)")
                        Divider()
                        DetailRow(label: "Elevator", value: request.hasElevator ? "Yes" : "No")
                    }
                    
                    if let notes = request.specialInstructions, !notes.isEmpty {
                        DetailSection(title: "Special Instructions") {
                            Text(notes).font(.body)
                        }
                    }
                    
                    DetailSection(title: "Assigned Movers") {
                        if (request.moverIds ?? []).isEmpty {
                            Text("No movers assigned yet").foregroundColor(.gray)
                        } else {
                            ForEach(request.moverIds ?? [], id: \.self) { moverId in
                                if let mover = authManager.allMovers.first(where: { $0.id == moverId }) {
                                    HStack(spacing: 10) {
                                        VStack(alignment: .leading) {
                                            Text(mover.displayName).font(.headline)
                                            Text(mover.email).font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if request.status != .completed {
                            Button(action: { showMoverPicker = true }) {
                                Label("Add Mover", systemImage: "person.badge.plus.fill")
                                    .font(.subheadline)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    if let requestId = request.id {
                        AdminNotesView(requestId: requestId)
                    }
                    
                    if let err = errorMessage {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red).font(.caption)
                    }
                    if let ok = successMessage {
                        Label(ok, systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green).font(.caption)
                    }
                    
                    VStack(spacing: 12) {
                        if request.status == .pending {
                            ActionButton(
                                title: "Accept Move Request",
                                color: Color("goodPurple"),
                                isWorking: isWorking
                            ) { await acceptRequest() }
                        }
                        
                        if request.status == .accepted {
                            ActionButton(
                                title: "Mark as Completed",
                                color: .green,
                                isWorking: isWorking
                            ) { await completeRequest() }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMoverPicker) {
            MoverPickerSheet(
                requestId: request.id ?? "",
                moveDate: request.createdAt ?? Date(),
                alreadyAssigned: request.moverIds ?? []
            ) { moverId in
                Task { await assignMover(moverId: moverId) }
            }
        }
    }
    
    
    private func acceptRequest() async {
        guard let id = request.id else { return }
        isWorking = true; errorMessage = nil
        do {
            try await svc.acceptRequest(id: id)
            request.status  = .accepted
            successMessage  = "Request accepted"
            await authManager.fetchAllMoveRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }
    
    private func completeRequest() async {
        guard let id = request.id else { return }
        isWorking = true; errorMessage = nil
        do {
            try await svc.completeRequest(id: id)
            request.status = .completed
            successMessage = "Move marked as completed"
            await authManager.fetchAllMoveRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }
    
    private func assignMover(moverId: String) async {
        guard let requestId = request.id,
              let adminId   = authManager.user?.id else { return }
        isWorking = true; errorMessage = nil
        do {
            try await svc.assignMover(requestId: requestId, moverId: moverId, adminId: adminId)
            if request.moverIds == nil { request.moverIds = [] }
            request.moverIds?.append(moverId)
            successMessage = request.status == .accepted
            ? "Mover added, added to group chat"
            : "Mover added"
            await authManager.fetchAllUsers()
            await authManager.fetchAllMoveRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }
}
    
    
    private struct ActionButton: View {
        let title: String
        let color: Color
        let isWorking: Bool
        let action: () async -> Void
        
        var body: some View {
            Button(action: { Task { await action() } }) {
                if isWorking {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text(title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .bold()
                }
            }
            .disabled(isWorking)
        }
    }

//
//  AllMovesView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import SwiftUI
import CoreData


struct AllMovesView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("All Move Requests")
                    .font(.largeTitle).bold()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                if authManager.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading ..."); Spacer() }
                    Spacer()

                } else if let err = authManager.moveRequestsError {
                    Spacer()
                    Text(err).foregroundColor(.red).padding(.horizontal, 20)
                    Spacer()

                } else if authManager.allMoveRequests.isEmpty {
                    Spacer()
                    Text("No move requests yet.").foregroundColor(.gray).padding(.horizontal, 20)
                    Spacer()

                } else {
                    let pending  = authManager.allMoveRequests.filter { $0.status == .pending }
                    let accepted = authManager.allMoveRequests.filter { $0.status == .accepted }
                    let done     = authManager.allMoveRequests.filter { $0.status == .completed }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if !pending.isEmpty {
                                SectionHeader(title: "Pending", color: .orange)
                                ForEach(pending) { req in
                                    NavigationLink(destination: MoveDetailAdminView(request: req)) {
                                        MoveRequestRow(request: req)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            if !accepted.isEmpty {
                                SectionHeader(title: "Accepted", color: Color("goodPurple"))
                                ForEach(accepted) { req in
                                    NavigationLink(destination: MoveDetailAdminView(request: req)) {
                                        MoveRequestRow(request: req)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            if !done.isEmpty {
                                SectionHeader(title: "Completed", color: .green)
                                ForEach(done) { req in
                                    NavigationLink(destination: MoveDetailAdminView(request: req)) {
                                        MoveRequestRow(request: req)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle("Move Requests")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            async let _ = authManager.fetchAllUsers()
            await authManager.fetchAllMoveRequests()
        }
        .refreshable {
            async let _ = authManager.fetchAllUsers()
            await authManager.fetchAllMoveRequests()
        }
    }
}


struct MoveDetailAdminView: View {
    @EnvironmentObject var authManager: AuthManager
    let request: MoveRequest

    @State private var showMoverPicker = false
    @State private var isWorking = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let svc = MoveRequestService()

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
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    DetailSection(title: "Pickup Address") {
                        Text(request.pickupAddress.addressLine).font(.body)
                        Text("\(request.pickupAddress.city), \(request.pickupAddress.province) \(request.pickupAddress.postalCode)")
                            .font(.subheadline).foregroundColor(.gray)
                    }

                    DetailSection(title: "Move Details") {
                        DetailRow(label: "Destination", value: request.destinationAddress.addressLine)
                        Divider()
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

                    DetailSection(title: "Assigned Mover") {
                        if let moverId = request.moverId,
                           let mover = authManager.allMovers.first(where: { $0.id == moverId }) {
                            HStack(spacing: 10) {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.orange)
                                    .cornerRadius(8)
                                VStack(alignment: .leading) {
                                    Text(mover.displayName).font(.headline)
                                    Text(mover.email).font(.caption).foregroundColor(.gray)
                                }
                            }
                        } else {
                            Text("No mover assigned yet").foregroundColor(.gray)
                        }

                        Button(action: { showMoverPicker = true }) {
                            Label("Change Mover", systemImage: "person.badge.plus.fill")
                                .font(.subheadline)
                        }
                        .padding(.top, 4)
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

                    if request.status == .pending {
                        Button(action: acceptRequest) {
                            if isWorking {
                                ProgressView().frame(maxWidth: .infinity).padding()
                            } else {
                                Text("Accept Move Request")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("goodPurple"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .bold()
                            }
                        }
                        .disabled(isWorking)
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
            MoverPickerSheet(requestId: request.id ?? "") { moverId in
                Task { await assignMover(moverId: moverId) }
            }
            .environmentObject(authManager)
        }
    }

    private func acceptRequest() {
        guard let id = request.id else { return }
        isWorking = true
        errorMessage = nil
        Task {
            do {
                try await svc.acceptRequest(id: id)
                successMessage = "Request accepted!"
                await authManager.fetchAllMoveRequests()
            } catch {
                errorMessage = error.localizedDescription
            }
            isWorking = false
        }
    }

    private func assignMover(moverId: String) async {
        guard let requestId = request.id,
              let adminId   = authManager.user?.id else { return }
        isWorking = true
        errorMessage = nil
        do {
            try await svc.assignMover(requestId: requestId, moverId: moverId, adminId: adminId)
            successMessage = request.status == .accepted
                ? "Mover assigned, group chat created"
                : "Mover assigned"
            await authManager.fetchAllMoveRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }
}


struct AdminNotesView: View {
    let requestId: String

    @Environment(\.managedObjectContext) private var context
    @State private var noteText = ""
    @State private var notes: [MoveNote] = []

    private var noteService: MoveNoteService {
        MoveNoteService(context: context)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Admin Notes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)

            if notes.isEmpty {
                Text("No notes yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.06))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(notes, id: \.objectID) { note in
                        NoteRow(note: note, onDelete: {
                            noteService.deleteNote(note)
                            loadNotes()
                        })
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Add a note", text: $noteText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                Button(action: submitNote) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color("goodPurple"))
                        .cornerRadius(10)
                }
                .disabled(noteText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear { loadNotes() }
    }

    private func submitNote() {
        noteService.addNote(text: noteText, requestId: requestId)
        noteText = ""
        loadNotes()
    }

    private func loadNotes() {
        notes = noteService.fetchNotes(for: requestId)
    }
}


private struct NoteRow: View {
    let note: MoveNote
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "note.text")
                .foregroundColor(Color("goodPurple"))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(note.text ?? "")
                    .font(.subheadline)
                    .foregroundColor(.black)
                if let date = note.createdAt {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.06))
        .cornerRadius(12)
    }
}


struct MoverPickerSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    let requestId: String
    let onSelect: (String) -> Void

    var body: some View {
        NavigationStack {
            List(authManager.allMovers) { mover in
                Button(action: {
                    if let id = mover.id {
                        onSelect(id)
                        dismiss()
                    }
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.orange)
                            .cornerRadius(10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mover.displayName).font(.headline)
                            Text(mover.email).font(.caption).foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select a Mover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if authManager.allMovers.isEmpty {
                    ContentUnavailableView(
                        "No movers found",
                        systemImage: "figure.walk",
                        description: Text("Create mover accounts first from the admin panel.")
                    )
                }
            }
        }
    }
}


private struct SectionHeader: View {
    let title: String
    let color: Color
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(color)
            .padding(.top, 4)
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding()
            .background(Color.gray.opacity(0.06))
            .cornerRadius(12)
        }
    }
}

struct StatusBadge: View {
    let status: MoveRequestStatus
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .cornerRadius(20)
    }
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .accepted: return Color("goodPurple")
        case .completed: return .green
        }
    }
}

struct MoveRequestRow: View {
    let request: MoveRequest
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "truck.box.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(statusColor(request.status))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(request.pickupAddress.addressLine)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Text("\(request.pickupAddress.city), \(request.pickupAddress.province)")
                    .font(.caption)
                    .foregroundColor(.gray)
                StatusBadge(status: request.status)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.06))
        .cornerRadius(14)
    }

    private func statusColor(_ s: MoveRequestStatus) -> Color {
        switch s {
        case .pending: return .orange
        case .accepted: return Color("goodPurple")
        case .completed: return .green
        }
    }
}

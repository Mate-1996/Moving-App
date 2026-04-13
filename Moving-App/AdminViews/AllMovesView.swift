//
//  AllMovesView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import SwiftUI
import CoreData
import FirebaseFirestore

struct AllMovesView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var searchText = ""

    private var filteredRequests: [MoveRequest] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return authManager.allMoveRequests
        }
        let query = searchText.lowercased()
        return authManager.allMoveRequests.filter { req in
            req.pickupAddress.addressLine.lowercased().contains(query) ||
            req.pickupAddress.city.lowercased().contains(query) ||
            req.pickupAddress.province.lowercased().contains(query) ||
            req.pickupAddress.postalCode.lowercased().contains(query) ||
            (req.destinationAddress?.addressLine.lowercased().contains(query) ?? false) ||
            (req.destinationAddress?.city.lowercased().contains(query) ?? false)
        }
    }

    private var pending:  [MoveRequest] { filteredRequests.filter { $0.status == .pending } }
    private var accepted: [MoveRequest] { filteredRequests.filter { $0.status == .accepted } }
    private var done: [MoveRequest] { filteredRequests.filter { $0.status == .completed } }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by address or city", text: $searchText)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                if authManager.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading"); Spacer() }
                    Spacer()

                } else if let err = authManager.moveRequestsError {
                    Spacer()
                    Text(err).foregroundColor(.red).padding(.horizontal, 20)
                    Spacer()

                } else if filteredRequests.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Text(searchText.isEmpty ? "No move requests yet." : "No results for \"\(searchText)\"")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()

                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if !pending.isEmpty {
                                SectionHeader(title: "Pending", color: .orange)
                                ForEach(pending) { req in
                                    NavigationLink(destination: MoveDetailAdminView(request: req)) {
                                        MoveRequestRow(request: req)
                                    }.buttonStyle(.plain)
                                }
                            }
                            if !accepted.isEmpty {
                                SectionHeader(title: "Accepted", color: Color("goodPurple"))
                                ForEach(accepted) { req in
                                    NavigationLink(destination: MoveDetailAdminView(request: req)) {
                                        MoveRequestRow(request: req)
                                    }.buttonStyle(.plain)
                                }
                            }
                            if !done.isEmpty {
                                SectionHeader(title: "Completed", color: .green)
                                ForEach(done) { req in
                                    NavigationLink(destination: MoveDetailAdminView(request: req)) {
                                        MoveRequestRow(request: req)
                                    }.buttonStyle(.plain)
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

struct AdminNotesView: View {
    let requestId: String

    @Environment(\.managedObjectContext) private var context
    @State private var noteText = ""
    @State private var notes: [MoveNote] = []

    private var noteService: MoveNoteService { MoveNoteService(context: context) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Admin Notes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)

            if notes.isEmpty {
                Text("No notes yet")
                    .font(.subheadline).foregroundColor(.gray)
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.06)).cornerRadius(12)
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
                        .foregroundColor(.white).padding(10)
                        .background(Color("goodPurple")).cornerRadius(10)
                }
                .disabled(noteText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear { loadNotes() }
    }

    private func submitNote() {
        noteService.addNote(text: noteText, requestId: requestId)
        noteText = ""; loadNotes()
    }

    private func loadNotes() { notes = noteService.fetchNotes(for: requestId) }
}

private struct NoteRow: View {
    let note: MoveNote
    let onDelete: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "note.text").foregroundColor(Color("goodPurple")).padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(note.text ?? "").font(.subheadline).foregroundColor(.black)
                if let date = note.createdAt {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2).foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash").font(.caption).foregroundColor(.red.opacity(0.7))
            }
        }
        .padding().background(Color.gray.opacity(0.06)).cornerRadius(12)
    }
}


struct MoverPickerSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    let requestId: String
    let moveDate: Date
    let alreadyAssigned: [String]
    let onSelect: (String) -> Void

    @State private var unavailableMoverIds: Set<String> = []
    @State private var busyMoverIds: Set<String> = []
    @State private var isChecking = true

    private let timeOffSvc = TimeOffService()

    var body: some View {
        NavigationStack {
            Group {
                if isChecking {
                    ProgressView("Checking availability")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(authManager.allMovers) { mover in
                        let onLeave = unavailableMoverIds.contains(mover.id ?? "")
                        let alreadyAdded = alreadyAssigned.contains(mover.id ?? "")
                        let isBusy = busyMoverIds.contains(mover.id ?? "")
                        let unavailable = onLeave || alreadyAdded || isBusy

                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mover.displayName)
                                    .font(.headline)
                                    .foregroundColor(unavailable ? .secondary : .primary)
                                Text(mover.email)
                                    .font(.caption).foregroundColor(.secondary)

                                if alreadyAdded {
                                    Text("Already assigned to this move")
                                        .font(.caption).foregroundColor(.blue)
                                } else if onLeave {
                                    Text("On approved time off")
                                        .font(.caption).foregroundColor(.red)
                                } else if isBusy {
                                    Text("Assigned to another active move")
                                        .font(.caption).foregroundColor(.orange)
                                }
                            }

                            Spacer()

                            if !unavailable {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard !unavailable, let id = mover.id else { return }
                            onSelect(id)
                            dismiss()
                        }
                        .opacity(unavailable ? 0.5 : 1)
                    }
                    .listStyle(.plain)
                    .overlay {
                        if authManager.allMovers.isEmpty {
                            ContentUnavailableView(
                                "No movers found",
                                systemImage: "figure.walk",
                                description: Text("Create mover accounts first.")
                            )
                        }
                    }
                }
            }
            .navigationTitle("Select a Mover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task { await checkAvailability() }
        }
    }

    private func checkAvailability() async {
        isChecking = true
        var onLeave = Set<String>()
        var busy = Set<String>()

        if let approvedLeave = try? await timeOffSvc.fetchApprovedLeave() {
            let cal = Calendar.current
            let checkDay = cal.startOfDay(for: moveDate)
            for req in approvedLeave {
                let s = cal.startOfDay(for: req.startDate)
                let e = cal.startOfDay(for: req.endDate)
                if checkDay >= s && checkDay <= e { onLeave.insert(req.moverId) }
            }
        }

        let db = Firestore.firestore()
        if let snap = try? await db.collection("moveRequests")
            .whereField("status", isEqualTo: MoveRequestStatus.accepted.rawValue)
            .getDocuments() {
            let requests = snap.documents.compactMap { try? $0.data(as: MoveRequest.self) }
            for req in requests {
                guard req.id != requestId else { continue }
                for moverId in req.moverIds ?? [] { busy.insert(moverId) }
            }
        }

        unavailableMoverIds = onLeave
        busyMoverIds = busy
        isChecking = false
    }
}


private struct SectionHeader: View {
    let title: String; let color: Color
    var body: some View {
        Text(title).font(.system(size: 13, weight: .semibold))
            .foregroundColor(color).padding(.top, 4)
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 8) { content() }
                .padding().background(Color.gray.opacity(0.06)).cornerRadius(12)
        }
    }
}

struct StatusBadge: View {
    let status: MoveRequestStatus
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor).cornerRadius(20)
    }
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .accepted:  return Color("goodPurple")
        case .completed: return .green
        }
    }
}

struct MoveRequestRow: View {
    let request: MoveRequest
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(request.pickupAddress.addressLine)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.black).lineLimit(1)
                Text("\(request.pickupAddress.city), \(request.pickupAddress.province)")
                    .font(.caption).foregroundColor(.gray)
                StatusBadge(status: request.status)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
        }
        .padding().background(Color.gray.opacity(0.06)).cornerRadius(14)
    }
    private func statusColor(_ s: MoveRequestStatus) -> Color {
        switch s {
        case .pending:   return .orange
        case .accepted:  return Color("goodPurple")
        case .completed: return .green
        }
    }
}

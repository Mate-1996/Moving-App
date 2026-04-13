//
//  AdminTimeOffView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-04-11.
//

import SwiftUI

struct AdminTimeOffView: View {
    @State private var requests: [TimeOffRequest] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let svc = TimeOffService()

    private var pending:  [TimeOffRequest] { requests.filter { $0.status == .pending } }
    private var approved: [TimeOffRequest] { requests.filter { $0.status == .approved } }
    private var rejected: [TimeOffRequest] { requests.filter { $0.status == .rejected } }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if isLoading {
                ProgressView("Loading")
            } else if requests.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundColor(Color(.systemGray3))
                    Text("No time off requests")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        if !pending.isEmpty {
                            AdminTimeOffSection(title: "Pending", color: .orange, requests: pending, svc: svc) {
                                Task { await loadRequests() }
                            }
                        }

                        if !approved.isEmpty {
                            AdminTimeOffSection(title: "Approved", color: .green, requests: approved, svc: svc) {
                                Task { await loadRequests() }
                            }
                        }

                        if !rejected.isEmpty {
                            AdminTimeOffSection(title: "Rejected", color: .red, requests: rejected, svc: svc) {
                                Task { await loadRequests() }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle("Mover Time Off")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadRequests() }
        .refreshable { await loadRequests() }
    }

    private func loadRequests() async {
        isLoading = true
        requests = (try? await svc.fetchAllRequests()) ?? []
        isLoading = false
    }
}


private struct AdminTimeOffSection: View {
    let title: String
    let color: Color
    let requests: [TimeOffRequest]
    let svc: TimeOffService
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)

            ForEach(requests) { req in
                AdminTimeOffCard(request: req, svc: svc, onRefresh: onRefresh)
            }
        }
    }
}


private struct AdminTimeOffCard: View {
    let request: TimeOffRequest
    let svc: TimeOffService
    let onRefresh: () -> Void

    @State private var isWorking = false

    private var dateRange: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return "\(fmt.string(from: request.startDate)) → \(fmt.string(from: request.endDate))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(request.moverName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(dateRange)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text("\(request.numberOfDays) day\(request.numberOfDays == 1 ? "" : "s") · \(request.year)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                statusBadge
            }

            if request.status == .pending {
                HStack(spacing: 10) {
                    ActionButton(label: "Approve", color: .green, isWorking: isWorking) {
                        await updateStatus(.approved)
                    }
                    ActionButton(label: "Reject", color: .red, isWorking: isWorking) {
                        await updateStatus(.rejected)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var statusBadge: some View {
        let color: Color = request.status == .approved ? .green : request.status == .rejected ? .red : .orange
        return Text(request.status.rawValue.capitalized)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(20)
    }

    private func updateStatus(_ status: TimeOffStatus) async {
        guard let id = request.id else { return }
        isWorking = true
        try? await svc.updateStatus(requestId: id, status: status)
        isWorking = false
        onRefresh()
    }
}


private struct ActionButton: View {
    let label: String
    let color: Color
    let isWorking: Bool
    let action: () async -> Void

    var body: some View {
        Button(action: { Task { await action() } }) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(color.opacity(0.1))
                .cornerRadius(10)
        }
        .disabled(isWorking)
    }
}

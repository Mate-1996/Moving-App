//
//  TimeOffView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-04-11.
//

import SwiftUI

struct TimeOffView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var requests:     [TimeOffRequest] = []
    @State private var isLoading     = false
    @State private var errorMessage: String?
    @State private var showForm      = false

    private let svc = TimeOffService()

    private var usedDaysThisYear: Int {
        let year = Calendar.current.component(.year, from: Date())
        return requests
            .filter { $0.year == year && $0.status != .rejected }
            .reduce(0) { $0 + $1.numberOfDays }
    }

    private var remainingDays: Int {
        max(0, TimeOffService.maxDaysPerYear - usedDaysThisYear)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vacation Days \(Calendar.current.component(.year, from: Date()))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("\(remainingDays) of \(TimeOffService.maxDaysPerYear) days remaining")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 6)
                            .frame(width: 56, height: 56)
                        Circle()
                            .trim(from: 0, to: CGFloat(usedDaysThisYear) / CGFloat(TimeOffService.maxDaysPerYear))
                            .stroke(Color("goodPurple"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))
                        Text("\(usedDaysThisYear)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("goodPurple"))
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color("goodPurple"))
                        .font(.system(size: 14))
                    Text("Requests must be made at least 2 weeks in advance and have to have admins approval")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color("goodPurple").opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if requests.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 44))
                            .foregroundColor(Color(.systemGray3))
                        Text("No time off requests yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(requests) { req in
                                TimeOffCard(request: req, onDelete: {
                                    Task { await deleteRequest(req) }
                                })
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle("Time Off")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { showForm = true }) {
                    Image(systemName: "plus")
                        .bold()
                }
                .disabled(remainingDays == 0)
            }
        }
        .sheet(isPresented: $showForm, onDismiss: { Task { await loadRequests() } }) {
            TimeOffFormView()
                .environmentObject(authManager)
        }
        .task { await loadRequests() }
        .refreshable { await loadRequests() }
    }

    private func loadRequests() async {
        guard let uid = authManager.user?.id else { return }
        isLoading = true
        requests = (try? await svc.fetchMyRequests(moverId: uid)) ?? []
        isLoading = false
    }

    private func deleteRequest(_ req: TimeOffRequest) async {
        guard let id = req.id, req.status == .pending else { return }
        try? await svc.deleteRequest(requestId: id)
        await loadRequests()
    }
}


struct TimeOffFormView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    private var earliestDate: Date {
        Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
    }

    @State private var startDate: Date
    @State private var endDate:   Date
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let svc = TimeOffService()

    init() {
        let earliest = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
        _startDate = State(initialValue: earliest)
        _endDate   = State(initialValue: earliest)
    }

    var numberOfDays: Int {
        let cal = Calendar.current
        let s = cal.startOfDay(for: startDate)
        let e = cal.startOfDay(for: endDate)
        return max(1, (cal.dateComponents([.day], from: s, to: e).day ?? 0) + 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 52))
                        .foregroundColor(Color("goodPurple"))
                        .padding(.top, 20)

                    VStack(spacing: 0) {
                        DatePickerRow(label: "Start Date", date: $startDate,
                                      range: earliestDate...)
                            .onChange(of: startDate) {
                                if endDate < startDate { endDate = startDate }
                            }
                        Divider().padding(.leading, 16)
                        DatePickerRow(label: "End Date", date: $endDate,
                                      range: startDate...)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    .padding(.horizontal, 20)

                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                        Text("\(numberOfDays) day\(numberOfDays == 1 ? "" : "s") selected")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.horizontal, 20)

                    if let err = errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(err)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }

                    Button(action: submit) {
                        if isSubmitting {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else {
                            Text("Submit Request")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("goodPurple"))
                                .cornerRadius(14)
                        }
                    }
                    .disabled(isSubmitting)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 30)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Request Time Off")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        guard let uid  = authManager.user?.id,
              let name = authManager.user?.displayName else { return }
        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                try await svc.submitTimeOff(moverId: uid, moverName: name, startDate: startDate, endDate: endDate)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}


private struct DatePickerRow: View {
    let label: String
    @Binding var date: Date
    let range: PartialRangeFrom<Date>

    var body: some View {
        DatePicker(label, selection: $date, in: range, displayedComponents: .date)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}


struct TimeOffCard: View {
    let request: TimeOffRequest
    let onDelete: () -> Void

    private var dateRange: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return "\(fmt.string(from: request.startDate)) → \(fmt.string(from: request.endDate))"
    }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 3)
                .fill(statusColor)
                .frame(width: 4, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(dateRange)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(request.numberOfDays) day\(request.numberOfDays == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(request.status.rawValue.capitalized)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(20)

                if request.status == .pending {
                    Button(action: onDelete) {
                        Text("Cancel")
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var statusColor: Color {
        switch request.status {
        case .pending:  return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

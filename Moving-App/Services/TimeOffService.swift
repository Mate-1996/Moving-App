//
//  TimeOffService.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-04-11.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TimeOffService {
    private let db = Firestore.firestore()

    static let maxDaysPerYear = 14
    static let minAdvanceDays = 14


    func submitTimeOff(moverId: String, moverName: String,
                       startDate: Date, endDate: Date) async throws {

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.startOfDay(for: startDate)
        let end = cal.startOfDay(for: endDate)

        // must be at least 14 days from today
        let daysFromNow = cal.dateComponents([.day], from: today, to: start).day ?? 0
        guard daysFromNow >= Self.minAdvanceDays else {
            throw TimeOffError.tooSoon
        }

        guard start <= end else {
            throw TimeOffError.invalidRange
        }

        let year = cal.component(.year, from: startDate)

        // check the remaining quota for this year
        let used = try await usedDays(moverId: moverId, year: year)
        let requested = cal.dateComponents([.day], from: start, to: end).day.map { $0 + 1 } ?? 1
        guard used + requested <= Self.maxDaysPerYear else {
            throw TimeOffError.quotaExceeded(remaining: Self.maxDaysPerYear - used)
        }

        // check if no other mover has approved time off conflicting these dates
        let conflict = try await hasConflict(excludingMoverId: moverId, start: start, end: end)
        guard !conflict else {
            throw TimeOffError.conflict
        }

        let request = TimeOffRequest(
            moverId: moverId,
            moverName: moverName,
            startDate: startDate,
            endDate: endDate,
            status: .pending,
            year: year
        )
        try db.collection("timeOffRequests").addDocument(from: request)
    }

    func fetchMyRequests(moverId: String) async throws -> [TimeOffRequest] {
        let snap = try await db.collection("timeOffRequests")
            .whereField("moverId", isEqualTo: moverId)
            .getDocuments()
        return try snap.documents
            .map { try $0.data(as: TimeOffRequest.self) }
            .sorted { $0.startDate < $1.startDate }
    }

    func fetchAllRequests() async throws -> [TimeOffRequest] {
        let snap = try await db.collection("timeOffRequests")
            .getDocuments()
        return try snap.documents
            .map { try $0.data(as: TimeOffRequest.self) }
            .sorted { $0.startDate < $1.startDate }
    }

    func updateStatus(requestId: String, status: TimeOffStatus) async throws {
        try await db.collection("timeOffRequests")
            .document(requestId)
            .updateData(["status": status.rawValue])
    }

    func deleteRequest(requestId: String) async throws {
        try await db.collection("timeOffRequests").document(requestId).delete()
    }

    func isMoverOnLeave(moverId: String, on date: Date) async -> Bool {
        let cal   = Calendar.current
        let check = cal.startOfDay(for: date)
        let snap  = try? await db.collection("timeOffRequests")
            .whereField("moverId", isEqualTo: moverId)
            .whereField("status", isEqualTo: TimeOffStatus.approved.rawValue)
            .getDocuments()

        guard let docs = snap?.documents else { return false }
        let requests = docs.compactMap { try? $0.data(as: TimeOffRequest.self) }
        return requests.contains { req in
            let s = cal.startOfDay(for: req.startDate)
            let e = cal.startOfDay(for: req.endDate)
            return check >= s && check <= e
        }
    }

    func fetchApprovedLeave() async throws -> [TimeOffRequest] {
        let snap = try await db.collection("timeOffRequests")
            .whereField("status", isEqualTo: TimeOffStatus.approved.rawValue)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: TimeOffRequest.self) }
    }


    private func usedDays(moverId: String, year: Int) async throws -> Int {
        let snap = try await db.collection("timeOffRequests")
            .whereField("moverId", isEqualTo: moverId)
            .whereField("year", isEqualTo: year)
            .getDocuments()

        let requests = snap.documents.compactMap { try? $0.data(as: TimeOffRequest.self) }
        return requests
            .filter { $0.status != .rejected }
            .reduce(0) { $0 + $1.numberOfDays }
    }

    private func hasConflict(excludingMoverId: String,
                             start: Date, end: Date) async throws -> Bool {
        let snap = try await db.collection("timeOffRequests")
            .whereField("status", isEqualTo: TimeOffStatus.approved.rawValue)
            .getDocuments()

        let others = snap.documents
            .compactMap { try? $0.data(as: TimeOffRequest.self) }
            .filter { $0.moverId != excludingMoverId }

        let cal = Calendar.current
        return others.contains { req in
            let s = cal.startOfDay(for: req.startDate)
            let e = cal.startOfDay(for: req.endDate)
            return start <= e && end >= s
        }
    }
}


enum TimeOffError: LocalizedError {
    case tooSoon
    case invalidRange
    case quotaExceeded(remaining: Int)
    case conflict

    var errorDescription: String? {
        switch self {
        case .tooSoon:
            return "Time off must be requested at least 2 weeks in advance."
        case .invalidRange:
            return "End date must be on or after the start date."
        case .quotaExceeded(let remaining):
            return "You only have \(remaining) days of vacation remaining this year."
        case .conflict:
            return "Another mover already has approved time off during those dates."
        }
    }
}

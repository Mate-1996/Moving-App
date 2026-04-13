//
//  TimeOffModels.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-04-11.
//

import Foundation
import FirebaseFirestore

enum TimeOffStatus: String, Codable {
    case pending
    case approved
    case rejected
}

struct TimeOffRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var moverId:     String
    var moverName:   String
    var startDate:   Date
    var endDate:     Date
    var status:      TimeOffStatus
    var year:        Int
    @ServerTimestamp var createdAt: Date?

    var numberOfDays: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: startDate)
        let end   = cal.startOfDay(for: endDate)
        return cal.dateComponents([.day], from: start, to: end).day.map { $0 + 1 } ?? 1
    }
}

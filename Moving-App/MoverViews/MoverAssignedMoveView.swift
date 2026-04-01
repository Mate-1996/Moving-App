//
//  MoverAssignedMoveView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-09.
//

import SwiftUI

struct MoverAssignedMoveView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 44))
                    .foregroundColor(.secondary)
                Text("Assigned Move")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .navigationTitle("Assigned Move")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoverAssignedMoveView()
}

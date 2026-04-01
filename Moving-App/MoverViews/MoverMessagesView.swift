//
//  MoverMessagingView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-09.
//

import SwiftUI

struct MoverMessagesView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 44))
                    .foregroundColor(.secondary)
                Text("Messages")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoverMessagesView()
}

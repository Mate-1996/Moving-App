//
//  ContentView.swift
//  MovingAppProject
//
//  Created by user285578 on 2/6/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            if let user = authManager.user {
                switch user.role {
                case .admin:
                    AdminView()
                case .mover:
                    MoverPage()
                case .regular:
                    UserView()
                }
            } else {
                RegisterView()
            }
        }
    }
}

#Preview {
    ContentView()
}

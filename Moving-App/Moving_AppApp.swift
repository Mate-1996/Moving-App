//
//  Moving_AppApp.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-02-06.
//

import SwiftUI
import CoreData

@main
struct Moving_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

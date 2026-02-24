//
//  ContentView.swift
//  MovingAppProject
//
//  Created by user285578 on 2/6/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthManager
    
    
    var body: some View {
        NavigationView {
            if authManager.user != nil {
                UserView()
            }else {
                RegisterView()
            }
        }
    }
}

#Preview {
    ContentView()
}

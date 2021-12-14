//
//  SessionsApp.swift
//  Shared
//
//  Created by Marquis Kurt on 14/12/21.
//

import SwiftUI

@main
struct SessionsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

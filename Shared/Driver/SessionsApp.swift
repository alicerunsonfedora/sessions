//
//  SessionsApp.swift
//  Shared
//
//  Created by Marquis Kurt on 14/12/21.
//

import SwiftUI

@main
struct SessionsApp: App {
    let persistenceController = PersistenceController.preview

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .newItem) {
                Button("New Project...") {
                    withAnimation {
                        let newProject = Project(context: persistenceController.container.viewContext)
                        newProject.name = "Untitled Project"
                        newProject.projectDescription = "No description provided."

                        do {
                            try persistenceController.container.viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
        }
    }
}

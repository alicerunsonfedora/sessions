//
//  ProjectView.swift
//  Sessions
//
//  Created by Marquis Kurt on 14/12/21.
//

import SwiftUI

struct ProjectView: View {
    var item: Project
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDeleteAlert: Bool = false
    @FetchRequest(fetchRequest: WorkItem.fetchRequest(), animation: .default)
    private var workItems: FetchedResults<WorkItem>

    init(item: Project) {
        self.item = item
        _workItems = FetchRequest<WorkItem>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \WorkItem.startDate, ascending: false)
            ],
            predicate: NSPredicate(format: "contributes = %@", item),
            animation: .default
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            #if os(iOS)
            Text(item.projectDescription ?? "No description provided.")
                .padding()
                .padding(.horizontal, 10)
            #endif
            List {
                Section("Active Items") {
                    ForEach(workItems.filter { $0.active == true }) { workItem in
                        NavigationLink {
                            ActiveSessionView(item: workItem)
                        } label: {
                            SessionListEntry(workItem: workItem, icon: "clock")
                        }
                        .contextMenu {
                            Button {
                                deleteWorkItem(item: workItem)
                            } label: {
                                Label("Delete Session", systemImage: "trash")
                            }
                            .keyboardShortcut(SwiftUI.KeyEquivalent.delete)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                finishSession(of: workItem)
                            } label: {
                                Label("Finish Session", systemImage: "clock.badge.checkmark")
                            }
                            .tint(.accentColor)
                        }
                        .swipeActions {
                            Button {
                                deleteWorkItem(item: workItem)
                            } label: {
                                Label("Delete Session", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }

                Section("Completed Items") {
                    ForEach(workItems.filter { $0.active == false }) { workItem in
                        NavigationLink {
                            ActiveSessionView(item: workItem)
                        } label: {
                            SessionListEntry(workItem: workItem, icon: "clock.badge.checkmark")
                        }
                        .contextMenu {
                            Button {
                                deleteWorkItem(item: workItem)
                            } label: {
                                Label("Delete Session", systemImage: "trash")
                            }
                            .keyboardShortcut(SwiftUI.KeyEquivalent.delete)
                        }
                        .swipeActions {
                            Button {
                                deleteWorkItem(item: workItem)
                            } label: {
                                Label("Delete Session", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .frame(minWidth: 200, idealWidth: 350)
        }
        .navigationTitle(item.name ?? "Project")
#if os(macOS)
        .navigationSubtitle(item.projectDescription ?? "No description provided.")
#endif
        .toolbar {
            ToolbarItem {
                Button {
                    addWorkItem(to: item)
                } label: {
                    Label("Add Work Item", systemImage: "calendar.badge.clock")
                }
            }
            #if os(iOS)
            ToolbarItem {
                EditButton()
            }
            #endif
            ToolbarItem {
                Button {
                    showDeleteAlert.toggle()
                } label: {
                    Label("Delete Project", systemImage: "folder.badge.minus")
                }
            }
        }
        .alert("Delete \(item.name ?? "Project")", isPresented: $showDeleteAlert) {
            Button(role: .cancel) {

            } label: {
                Text("Don't Delete")
            }
            Button(role: .destructive) {
                deleteItem(item: item)
            } label: {
                Text("Delete")
            }
        } message: {
            Text("The project and its associated work items will be deleted. This action cannot be undone.")
        }
    }

    private func finishSession(of item: WorkItem) {
        item.endDate = Date()
        item.active = false
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("An error occured: \(nsError)")
        }
    }

    private func deleteItem(item: Project) {
        withAnimation {
            viewContext.delete(item)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func addWorkItem(to project: Project) {
        withAnimation {
            let workItem = WorkItem(context: viewContext)
            workItem.active = true
            workItem.type = "Development"
            workItem.startDate = Date()
            workItem.contributes = project

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteWorkItem(item: WorkItem) {
        withAnimation {
            viewContext.delete(item)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func deleteWorkItems(offsets: IndexSet) {
        withAnimation {
            for offset in offsets {
                let workItem = workItems[offset]
                viewContext.delete(workItem)
            }

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let sampleItem = Project(context: viewContext)
        sampleItem.name = "Sessions"
        sampleItem.projectDescription = "A project with work items"

        for j in 0..<3 {
            let newItem = WorkItem(context: viewContext)
            newItem.startDate = Date()
            newItem.endDate = Calendar.current.date(byAdding: .hour, value: j, to: Date())
            newItem.type = ["Development", "Documentation", "Testing"].randomElement() ?? "Some work"
            newItem.active = false
            newItem.contributes = sampleItem
        }

        let newItem = WorkItem(context: viewContext)
        newItem.startDate = Date()
        newItem.type = ["Development", "Documentation", "Testing"].randomElement() ?? "Some work"
        newItem.active = true
        newItem.contributes = sampleItem
        newItem.summary = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """


        return NavigationView {
            ProjectView(item: sampleItem).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

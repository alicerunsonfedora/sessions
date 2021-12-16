//
//  ContentView.swift
//  Shared
//
//  Created by Marquis Kurt on 14/12/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Project>

    @State private var showNewWizard = false
    @State private var projectName = ""
    @State private var projectDesc = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ProjectView(item: item)
                    } label: {
                        Label(item.name ?? "Unknown Project", systemImage: "folder")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Sessions")
            .frame(minWidth: 150, idealWidth: 200)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
                ToolbarItem {
                    Button {
                        showNewWizard.toggle()
                    } label: {
                        Label("Add Item", systemImage: "folder.badge.plus")
                    }
                }
            }
            Text("No Session Selected")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No Session Selected")
                .font(.largeTitle)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showNewWizard) {
            VStack(alignment: .leading) {
                HStack {
                    Text("New Project")
                        .bold()
                    #if os(iOS)
                        .padding(.top, 64)
                    #endif
                    #if os(iOS)
                    Spacer()
                    Button {
                        showNewWizard = false
                        addItem()
                    } label: {
                        Label("Create", systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    #endif
                }

                Form {
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Description", text: $projectDesc)
                        .textFieldStyle(.roundedBorder)
                }
                #if os(macOS)
                HStack {
                    Spacer()
                    #if os(macOS)
                    Button {
                        showNewWizard = false
                    } label: {
                        Text("Cancel")
                    }
                    #endif
                    Button {
                        showNewWizard = false
                        addItem()
                    } label: {
                        Label("Create", systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                #endif

            }
            .padding()
            .frame(width: 400, height: 150)
        }

    }

    private func addItem() {
        withAnimation {
            let newProject = Project(context: viewContext)
            newProject.name = projectName
            newProject.projectDescription = projectDesc

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

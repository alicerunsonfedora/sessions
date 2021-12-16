//
//  ActiveWorkView.swift
//  Sessions
//
//  Created by Marquis Kurt on 14/12/21.
//

import SwiftUI

struct ActiveSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: WorkItem
    @State var itemType: WorkItem.Types = .other
    @State var summary = ""

    var body: some View {
        VStack {
            Form {
                Section("Statistics") {
                    HStack {
                        Text("Started")
                        Spacer()
                        if let startDate = item.startDate {
                            Text(startDate, format: .dateTime)
                                .foregroundColor(.secondary)
                        }
                    }
                    if let endDate = item.endDate {
                        HStack {
                            Text("Finished")
                            Spacer()
                                Text(endDate, format: .dateTime)
                                    .foregroundColor(.secondary)
                        }
                    }
                }
                Section {
                    Picker("Session Type", selection: $itemType) {
                        ForEach(WorkItem.Types.allCases, id: \.self) { caseType in
                            Text(caseType.rawValue).tag(caseType)
                        }
                    }
                    .onChange(of: itemType) { value in
                        item.type = value.rawValue
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            print("An error occured: \(nsError)")
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $summary)
                        .onChange(of: summary) { value in
                            item.summary = summary
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                print("An error occured: \(nsError)")
                            }
                        }
                        .frame(minHeight: 300)
                }

            }
        }
        #if os(macOS)
        .padding()
        .background(.background)
        #endif
        .navigationTitle("Work Session")
        .onAppear {
            if let workType = item.type {
                itemType = .init(rawValue: workType) ?? .other
            }
            if let workSummary = item.summary {
                summary = workSummary
            }
        }
        .toolbar {
            ToolbarItem {
                if item.active {
                    Button {
                        withAnimation {
                            item.active = false
                            print("FIRE! \(item.active)")
                            item.endDate = Date()
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                print("An error occured: \(nsError)")
                            }
                        }
                    } label: {
                        Label("End Session", systemImage: "clock.badge.checkmark")
                    }
                }
            }

            ToolbarItem {
                Button {
                    copyCommand()
                } label: {
                    Label("Copy Command", systemImage: "doc.on.doc")
                }
            }

//            ToolbarItem {
//                Button {
//                    withAnimation {
//                        viewContext.delete(item)
//                        do {
//                            try viewContext.save()
//                        } catch {
//                            let nsError = error as NSError
//                            print("An error occured: \(nsError)")
//                        }
//                    }
//                } label: {
//                    Label("Delete Session", systemImage: "trash")
//                }
//            }

        }
    }

    func copyCommand() {
        if let command = makeCommandOrNil() {
            #if os(iOS)
            UIPasteboard.general.string = command
            #else
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(command, forType: .string)
            #endif
        }
    }

    func makeCommandOrNil() -> String? {
        guard let components: DateComponents = item.getDuration() else { return nil }
        var command = "work \(item.type ?? "") "
        if let day = components.day { command += "\(day)d " }
        if let hour = components.hour { command += "\(hour)h " }
        if let minute = components.minute { command += "\(minute)m " }
        if let second = components.second { command += "\(second)s " }
        return command
    }

}

struct ActiveSessionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let sampleItem = Project(context: viewContext)
        sampleItem.name = "Sessions"
        sampleItem.projectDescription = "A project with work items"

        let newItem = WorkItem(context: viewContext)
        newItem.startDate = Date()
        newItem.type = ["Development", "Documentation", "Testing"].randomElement() ?? "Some work"
        newItem.active = true
        newItem.contributes = sampleItem

        let completeItem = WorkItem(context: viewContext)
        completeItem.startDate = Date()
        completeItem.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        completeItem.type = ["Development", "Documentation", "Testing"].randomElement() ?? "Some work"
        completeItem.active = false
        completeItem.contributes = sampleItem

        return Group {
            ActiveSessionView(item: newItem).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ActiveSessionView(item: completeItem).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

            NavigationView {
                ActiveSessionView(item: newItem).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .previewDevice("iPhone 13")
            NavigationView {
                ActiveSessionView(item: completeItem).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .previewDevice("iPhone 13")
        }



    }
}

//
//  SessionListEntry.swift
//  Sessions (iOS)
//
//  Created by Marquis Kurt on 15/12/21.
//

import SwiftUI
import CoreData

struct SessionListEntry: View {
    @ObservedObject var workItem: WorkItem
    @State var icon: String

    var body: some View {
        VStack(alignment: .leading) {
            Label {
                VStack(alignment: .leading) {
                    HStack {
                        Text(workItem.type ?? "Unknown Work Type")
                            .bold()
                        Spacer()
                        if workItem.active == true {
                            Text("Active")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        else {
                            if let duration = workItem.getDuration() {
                                Text(duration, format: .timeDuration)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if let summary = workItem.summary {
                        Text(summary)
                            .lineLimit(2)
                            .padding(.bottom, 1)
                    }

                    if workItem.active {
                        if let startDate = workItem.startDate {
                            Text(startDate, format: Date.FormatStyle(
                                date: .numeric, time: .shortened
                            ))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    } else {
                        if let endDate = workItem.endDate {
                            Text(endDate, format: .relative(presentation: .numeric))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct SessionListEntry_Previews: PreviewProvider {
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
        newItem.summary = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """
        return SessionListEntry(workItem: newItem, icon: "clock")
            .padding()
            .frame(maxWidth: 400)
    }
}

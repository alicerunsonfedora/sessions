//
//  WorkItemTypes.swift
//  Sessions
//
//  Created by Marquis Kurt on 14/12/21.
//

import Foundation
import CoreData

extension WorkItem {
    public enum Types: String, CaseIterable {
        case development = "Development"
        case writing = "Writing"
        case docs = "Documentation"
        case testing = "Testing"
        case artwork = "Artwork"
        case brainstorm = "Planning"
        case other = "Other"
    }

    func getDuration() -> Range<Date>? {
        guard let end = self.endDate else { return nil }
        guard let start = self.startDate else { return nil }
        return start..<end
    }

    func getDuration() -> DateComponents? {
        guard let end = self.endDate else { return nil }
        guard let start = self.startDate else { return nil }
        return Calendar.current.dateComponents([.day, .hour, .minute, .second], from: start, to: end)
    }
}

//
//  GoalStore.swift
//  Intention
//
//  Shared data store used by BOTH the app and the widget extension.
//  Persists up to 6 goals as JSON in the shared App Group UserDefaults.
//
//  ⚠️ Target membership: add this file to the "IntentionWidgetExtensionExtension"
//     target in Xcode (File Inspector → Target Membership). It already belongs
//     to the "Intention" app target because it lives in the synchronized folder.
//

import Foundation
import WidgetKit

enum GoalStore {
    /// Shared App Group container (configured on both targets).
    static let appGroupID = "group.com.lev.Intention"

    /// Maximum number of goals kept at once.
    static let maxGoals = 6

    private static let goalsKey = "goals"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Load the saved goals (empty array if none / decode fails).
    /// `nonisolated` so it behaves identically in both targets regardless of
    /// each target's default actor isolation setting.
    nonisolated static func load() -> [Goal] {
        guard let data = defaults?.data(forKey: goalsKey) else { return [] }
        return (try? JSONDecoder().decode([Goal].self, from: data)) ?? []
    }

    /// Save goals (capped at `maxGoals`) and refresh the widget immediately.
    nonisolated static func save(_ goals: [Goal]) {
        let limited = Array(goals.prefix(maxGoals))
        guard let data = try? JSONEncoder().encode(limited) else { return }
        defaults?.set(data, forKey: goalsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Toggle a single goal's `isDone` by id, then persist + reload the widget.
    /// Called from the widget's AppIntent so a tap updates shared state directly.
    nonisolated static func toggle(id: UUID) {
        var goals = load()
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[index].isDone.toggle()
        save(goals)
    }
}

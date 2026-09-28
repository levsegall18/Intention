//
//  AppIntent.swift
//  IntentionWidgetExtension
//
//  Interactive intent: toggles a single goal's done-state directly from the
//  home screen widget, without opening the app. Updates the shared store and
//  (via GoalStore.save) reloads the widget timeline.
//

import AppIntents

struct ToggleGoalIntent: AppIntent {
    static var title: LocalizedStringResource { "Toggle Intention" }
    static var description: IntentDescription { "Checks or unchecks an intention." }

    @Parameter(title: "Goal ID")
    var goalID: String

    init() {}

    init(goalID: String) {
        self.goalID = goalID
    }

    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: goalID) {
            GoalStore.toggle(id: id)
        }
        return .result()
    }
}

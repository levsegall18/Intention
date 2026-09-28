//
//  IntentionWidgetExtension.swift
//  IntentionWidgetExtension
//
//  Home-screen (medium, large) and lock-screen (rectangular, circular, inline) widget
//  that shows today's intentions. Each row's
//  checkmark is a Button(intent:) that toggles the goal via ToggleGoalIntent —
//  no app launch, no deep link.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline

struct GoalEntry: TimelineEntry {
    let date: Date
    let goals: [Goal]
}

struct Provider: TimelineProvider {
    private var sampleGoals: [Goal] {
        [
            Goal(text: "Write today's intentions"),
            Goal(text: "Move for 20 minutes", isDone: true),
            Goal(text: "Read a chapter")
        ]
    }

    func placeholder(in context: Context) -> GoalEntry {
        GoalEntry(date: Date(), goals: sampleGoals)
    }

    func getSnapshot(in context: Context, completion: @escaping (GoalEntry) -> Void) {
        let goals = context.isPreview ? sampleGoals : GoalStore.load()
        completion(GoalEntry(date: Date(), goals: goals))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GoalEntry>) -> Void) {
        let entry = GoalEntry(date: Date(), goals: GoalStore.load())
        // We refresh explicitly via WidgetCenter after edits, so no time policy needed.
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: - View

struct IntentionWidgetExtensionEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(goals: entry.goals)
        case .accessoryRectangular:
            AccessoryRectangularView(goals: entry.goals)
        case .accessoryInline:
            AccessoryInlineView(goals: entry.goals)
        default:
            HomeScreenView(goals: entry.goals)
        }
    }
}

// MARK: - Home screen

private struct HomeScreenView: View {
    let goals: [Goal]

    var body: some View {
        if goals.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("No intentions yet")
                    .font(.headline)
                Text("Open Intention to add today's goals.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            AdaptiveGoalList(goals: goals, style: .homeScreen)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Adaptive goal list

/// Fits as many goals as the widget allows. ViewThatFits tries each layout in
/// order and uses the first that fits vertically:
///   1. every goal at the regular size
///   2. every goal at a compact size (smaller font, tighter spacing)
///   3. a capped list — unfinished goals first — with a "+N more" line
private struct AdaptiveGoalList: View {
    enum Style { case homeScreen, lockScreen }

    let goals: [Goal]
    let style: Style
    @Environment(\.widgetFamily) private var family

    /// Rows shown in the capped fallback, leaving room for the "+N more" line.
    private var cappedRowCount: Int {
        switch family {
        case .accessoryRectangular: 2
        case .systemLarge: 9
        default: 4
        }
    }

    /// Unfinished goals first so the capped list shows what's left to do.
    private var prioritizedGoals: [Goal] {
        goals.filter { !$0.isDone } + goals.filter(\.isDone)
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            rows(goals, compact: false)
            rows(goals, compact: true)
            capped
        }
    }

    private var capped: some View {
        let shown = Array(prioritizedGoals.prefix(cappedRowCount))
        let hidden = goals.count - shown.count
        return VStack(alignment: .leading, spacing: compactSpacing) {
            rows(shown, compact: true)
            if hidden > 0 {
                Text("+\(hidden) more")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var compactSpacing: CGFloat { style == .homeScreen ? 3 : 0 }

    private func rows(_ goals: [Goal], compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? compactSpacing : (style == .homeScreen ? 6 : 2)) {
            ForEach(goals) { goal in
                GoalRow(goal: goal, style: style, compact: compact)
            }
        }
    }
}

private struct GoalRow: View {
    let goal: Goal
    let style: AdaptiveGoalList.Style
    let compact: Bool

    private var font: Font {
        switch (style, compact) {
        case (.homeScreen, false): .subheadline
        case (.homeScreen, true): .caption
        case (.lockScreen, false): .caption
        case (.lockScreen, true): .caption2
        }
    }

    var body: some View {
        HStack(spacing: style == .homeScreen ? 8 : 4) {
            Button(intent: ToggleGoalIntent(goalID: goal.id.uuidString)) {
                icon
            }
            .buttonStyle(.plain)

            Text(goal.text)
                .strikethrough(goal.isDone)
                .foregroundStyle(style == .homeScreen && goal.isDone ? .secondary : .primary)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .font(font)
    }

    @ViewBuilder private var icon: some View {
        let image = Image(systemName: goal.isDone ? "checkmark.circle.fill" : "circle")
        switch style {
        case .homeScreen:
            image.foregroundStyle(goal.isDone ? Color.green : Color.secondary)
        case .lockScreen:
            image.widgetAccentable()
        }
    }
}

// MARK: - Lock screen

/// Progress ring showing how many of today's intentions are done.
private struct AccessoryCircularView: View {
    let goals: [Goal]

    private var doneCount: Int { goals.filter(\.isDone).count }

    var body: some View {
        Gauge(value: Double(doneCount), in: 0...Double(max(goals.count, 1))) {
            Image(systemName: "checkmark")
        } currentValueLabel: {
            Text("\(doneCount)/\(goals.count)")
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .widgetAccentable()
    }
}

/// Intentions with tappable checkmarks, shrinking or capping to fit.
private struct AccessoryRectangularView: View {
    let goals: [Goal]

    var body: some View {
        if goals.isEmpty {
            VStack(alignment: .leading) {
                Text("No intentions yet")
                    .font(.headline)
                    .widgetAccentable()
                Text("Open Intention to add some.")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            AdaptiveGoalList(goals: goals, style: .lockScreen)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Single line of text above the clock.
private struct AccessoryInlineView: View {
    let goals: [Goal]

    var body: some View {
        if goals.isEmpty {
            Text("No intentions yet")
        } else {
            let doneCount = goals.filter(\.isDone).count
            Label("\(doneCount) of \(goals.count) intentions done", systemImage: "checkmark.circle")
        }
    }
}

// MARK: - Widget

struct IntentionWidgetExtension: Widget {
    let kind: String = "IntentionWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            IntentionWidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Intentions")
        .description("See and check off your intentions from the home or lock screen.")
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

private let previewGoals = [
    Goal(text: "Write today's intentions"),
    Goal(text: "Move for 20 minutes", isDone: true),
    Goal(text: "Read a chapter")
]

private let manyPreviewGoals = previewGoals + [
    Goal(text: "Call a friend"),
    Goal(text: "Plan tomorrow", isDone: true),
    Goal(text: "Drink 8 glasses of water"),
    Goal(text: "Stretch before bed")
]

#Preview(as: .systemMedium) {
    IntentionWidgetExtension()
} timeline: {
    GoalEntry(date: .now, goals: previewGoals)
    GoalEntry(date: .now, goals: Array(manyPreviewGoals.prefix(4)))
    GoalEntry(date: .now, goals: manyPreviewGoals)
}

#Preview(as: .systemLarge) {
    IntentionWidgetExtension()
} timeline: {
    GoalEntry(date: .now, goals: manyPreviewGoals)
}

#Preview(as: .accessoryRectangular) {
    IntentionWidgetExtension()
} timeline: {
    GoalEntry(date: .now, goals: previewGoals)
    GoalEntry(date: .now, goals: Array(manyPreviewGoals.prefix(4)))
    GoalEntry(date: .now, goals: manyPreviewGoals)
}

#Preview(as: .accessoryCircular) {
    IntentionWidgetExtension()
} timeline: {
    GoalEntry(date: .now, goals: previewGoals)
}

#Preview(as: .accessoryInline) {
    IntentionWidgetExtension()
} timeline: {
    GoalEntry(date: .now, goals: previewGoals)
}

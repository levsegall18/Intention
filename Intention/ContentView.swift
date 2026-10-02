//
//  ContentView.swift
//  Intention
//
//  Main app screen: add / list / check off today's intentions.
//  Text editing and deleting happen only in edit mode (the Edit button).
//  Every change persists through GoalStore.save(), which also reloads the widget.
//

import SwiftUI

struct ContentView: View {
    @State private var goals: [Goal] = GoalStore.load()
    @State private var newGoalText: String = ""
    /// Owned here (rather than read from the environment) so the rows can
    /// switch between check-off mode and text-editing mode.
    @State private var editMode: EditMode = .inactive

    /// Each goal's text as it was when edit mode began, so a goal whose text
    /// is cleared while editing keeps its previous text.
    @State private var textBeforeEditing: [Goal.ID: String] = [:]

    private var trimmedNewGoal: String {
        newGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAdd: Bool {
        !trimmedNewGoal.isEmpty && goals.count < GoalStore.maxGoals
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($goals) { $goal in
                        Group {
                            if editMode.isEditing {
                                TextField("Intention", text: $goal.text)
                                    .submitLabel(.done)
                            } else {
                                Button {
                                    goal.isDone.toggle()
                                    persist()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: goal.isDone ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(goal.isDone ? Color.green : Color.secondary)

                                        Text(goal.text)
                                            .strikethrough(goal.isDone)
                                            .foregroundStyle(goal.isDone ? .secondary : .primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(goal.isDone ? .isSelected : [])
                            }
                        }
                        // No swipe-to-delete outside edit mode: checking off is the only action.
                        .deleteDisabled(!editMode.isEditing)
                    }
                    .onDelete(perform: delete)
                } header: {
                    Text("Intentions")
                } footer: {
                    Text("\(goals.count) of \(GoalStore.maxGoals)")
                }

                if goals.count < GoalStore.maxGoals {
                    Section {
                        HStack {
                            TextField("New intention", text: $newGoalText)
                                .onSubmit(add)
                            Button("Add", action: add)
                                .disabled(!canAdd)
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                if !goals.isEmpty || editMode.isEditing {
                    EditButton()
                }
            }
            .onChange(of: editMode) { _, newValue in
                if newValue.isEditing {
                    textBeforeEditing = Dictionary(uniqueKeysWithValues: goals.map { ($0.id, $0.text) })
                } else {
                    commitEdits()
                }
            }
        }
        .environment(\.editMode, $editMode)
    }

    /// Saves text edited in edit mode. Text is trimmed, and blank text is
    /// discarded so the goal keeps its previous text.
    private func commitEdits() {
        for index in goals.indices {
            let trimmed = goals[index].text.trimmingCharacters(in: .whitespacesAndNewlines)
            goals[index].text = trimmed.isEmpty
                ? textBeforeEditing[goals[index].id, default: trimmed]
                : trimmed
        }
        textBeforeEditing = [:]
        persist()
    }

    private func add() {
        guard canAdd else { return }
        goals.append(Goal(text: trimmedNewGoal))
        newGoalText = ""
        persist()
    }

    private func delete(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        GoalStore.save(goals)
    }
}

#Preview {
    ContentView()
}

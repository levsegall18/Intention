//
//  ContentView.swift
//  Intention
//
//  Main app screen: add / list / delete / check off today's intentions.
//  Every change persists through GoalStore.save(), which also reloads the widget.
//

import SwiftUI

struct ContentView: View {
    @State private var goals: [Goal] = GoalStore.load()
    @State private var newGoalText: String = ""

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
                        HStack(spacing: 12) {
                            Button {
                                goal.isDone.toggle()
                                persist()
                            } label: {
                                Image(systemName: goal.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(goal.isDone ? Color.green : Color.secondary)
                            }
                            .buttonStyle(.plain)

                            Text(goal.text)
                                .strikethrough(goal.isDone)
                                .foregroundStyle(goal.isDone ? .secondary : .primary)
                        }
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
                if !goals.isEmpty {
                    EditButton()
                }
            }
        }
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

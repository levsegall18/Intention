//
//  Goal.swift
//  Intention
//
//  Shared model used by BOTH the app and the widget extension.
//  ⚠️ Target membership: add this file to the "IntentionWidgetExtensionExtension"
//     target in Xcode (File Inspector → Target Membership). It already belongs
//     to the "Intention" app target because it lives in the synchronized folder.
//

import Foundation

struct Goal: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var isDone: Bool

    init(id: UUID = UUID(), text: String, isDone: Bool = false) {
        self.id = id
        self.text = text
        self.isDone = isDone
    }
}

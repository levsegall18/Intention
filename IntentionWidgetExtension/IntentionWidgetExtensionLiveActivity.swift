//
//  IntentionWidgetExtensionLiveActivity.swift
//  IntentionWidgetExtension
//
//  Created by Lev Segall on 2026-09-27.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct IntentionWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct IntentionWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IntentionWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension IntentionWidgetExtensionAttributes {
    fileprivate static var preview: IntentionWidgetExtensionAttributes {
        IntentionWidgetExtensionAttributes(name: "World")
    }
}

extension IntentionWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: IntentionWidgetExtensionAttributes.ContentState {
        IntentionWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: IntentionWidgetExtensionAttributes.ContentState {
         IntentionWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: IntentionWidgetExtensionAttributes.preview) {
   IntentionWidgetExtensionLiveActivity()
} contentStates: {
    IntentionWidgetExtensionAttributes.ContentState.smiley
    IntentionWidgetExtensionAttributes.ContentState.starEyes
}

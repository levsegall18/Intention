//
//  IntentionWidgetExtensionBundle.swift
//  IntentionWidgetExtension
//
//  Created by Lev Segall on 2026-09-27.
//

import WidgetKit
import SwiftUI

@main
struct IntentionWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        IntentionWidgetExtension()
        IntentionWidgetExtensionControl()
        IntentionWidgetExtensionLiveActivity()
    }
}

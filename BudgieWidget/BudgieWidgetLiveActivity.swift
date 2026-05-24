//
//  BudgieWidgetLiveActivity.swift
//  BudgieWidget
//
//  Created by Ruba Alghamdi on 07/12/1447 AH.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BudgieWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BudgieWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BudgieWidgetAttributes.self) { context in
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

extension BudgieWidgetAttributes {
    fileprivate static var preview: BudgieWidgetAttributes {
        BudgieWidgetAttributes(name: "World")
    }
}

extension BudgieWidgetAttributes.ContentState {
    fileprivate static var smiley: BudgieWidgetAttributes.ContentState {
        BudgieWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BudgieWidgetAttributes.ContentState {
         BudgieWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BudgieWidgetAttributes.preview) {
   BudgieWidgetLiveActivity()
} contentStates: {
    BudgieWidgetAttributes.ContentState.smiley
    BudgieWidgetAttributes.ContentState.starEyes
}

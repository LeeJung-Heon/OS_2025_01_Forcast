//
//  fcstWidgetLiveActivity.swift
//  fcstWidget
//
//  Created by Hyeok Jung Kwon on 5/29/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct fcstWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct fcstWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: fcstWidgetAttributes.self) { context in
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

extension fcstWidgetAttributes {
    fileprivate static var preview: fcstWidgetAttributes {
        fcstWidgetAttributes(name: "World")
    }
}

extension fcstWidgetAttributes.ContentState {
    fileprivate static var smiley: fcstWidgetAttributes.ContentState {
        fcstWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: fcstWidgetAttributes.ContentState {
         fcstWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: fcstWidgetAttributes.preview) {
   fcstWidgetLiveActivity()
} contentStates: {
    fcstWidgetAttributes.ContentState.smiley
    fcstWidgetAttributes.ContentState.starEyes
}

import ActivityKit
import SwiftUI
import WidgetKit

private let appGroupId = "group.com.driveflow.driveflow"

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {}

    public var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

@available(iOS 16.1, *)
struct DriveFlowShiftLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            ShiftLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ShiftLiveActivityView(context: context, compact: true)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            } compactTrailing: {
                Text(readValue(context, key: "elapsedLabel"))
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            }
        }
    }
}

@available(iOS 16.1, *)
private struct ShiftLiveActivityView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var compact: Bool = false

    var body: some View {
        let title = readValue(context, key: "title")
        let revenue = readValue(context, key: "revenueLabel")
        let elapsed = readValue(context, key: "elapsedLabel")
        let subtitle = readValue(context, key: "subtitle")

        VStack(alignment: .leading, spacing: compact ? 2 : 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            Text(revenue)
                .font(compact ? .headline.bold() : .title2.bold())
                .foregroundColor(.white)
            if !compact {
                Text(subtitle.isEmpty ? elapsed : "\(elapsed) · \(subtitle)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(compact ? 8 : 16)
        .activityBackgroundTint(Color(red: 0, green: 0.392, blue: 0.961))
        .activitySystemActionForegroundColor(.white)
    }
}

@available(iOS 16.1, *)
private func readValue(
    _ context: ActivityViewContext<LiveActivitiesAppAttributes>,
    key: String,
) -> String {
    let sharedDefault = UserDefaults(suiteName: appGroupId)
    return sharedDefault?.string(forKey: context.attributes.prefixedKey(key)) ?? ""
}

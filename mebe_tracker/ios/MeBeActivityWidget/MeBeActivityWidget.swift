import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Activity Attributes
//
// The `live_activities` Flutter plugin does not deliver data through a custom
// ActivityAttributes.ContentState. It always creates
// `Activity<LiveActivitiesAppAttributes>` natively and writes the Dart-side
// data map into shared UserDefaults, keyed by "<activityId>_<key>". This type
// must match that contract exactly or the system has no widget configuration
// to render the activity the plugin creates.

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

// MARK: - Shared data reader

private let appGroupId = "group.com.mebe.mebetracker"
private let sharedDefaults = UserDefaults(suiteName: appGroupId)

struct TimerData {
    let timerType: String
    let label: String
    let startTime: Date
    let totalTargetSeconds: Int
    let babyName: String

    init(attributes: LiveActivitiesAppAttributes) {
        func value(_ key: String) -> String { attributes.prefixedKey(key) }

        timerType = sharedDefaults?.string(forKey: value("timerType")) ?? "feeding"
        label = sharedDefaults?.string(forKey: value("label")) ?? ""
        babyName = sharedDefaults?.string(forKey: value("babyName")) ?? "Bé"
        totalTargetSeconds = sharedDefaults?.integer(forKey: value("totalTargetSeconds")) ?? 0

        let startMs = sharedDefaults?.double(forKey: value("startTime"))
        if let startMs, startMs > 0 {
            startTime = Date(timeIntervalSince1970: startMs / 1000)
        } else {
            startTime = Date()
        }
    }
}

// MARK: - Live Activity Widget

@available(iOSApplicationExtension 16.1, *)
struct MeBeActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock-screen / banner view
            LockScreenView(data: TimerData(attributes: context.attributes))
        } dynamicIsland: { context in
            let data = TimerData(attributes: context.attributes)
            return DynamicIsland {
                // Expanded view (long-press)
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(data: data)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(data: data)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(data: data)
                }
            } compactLeading: {
                CompactLeadingView(data: data)
            } compactTrailing: {
                CompactTrailingView(data: data)
            } minimal: {
                MinimalView(data: data)
            }
            .widgetURL(URL(string: "mebe://timer/\(data.babyName)"))
        }
    }
}

// MARK: - Lock Screen View

@available(iOSApplicationExtension 16.1, *)
struct LockScreenView: View {
    let data: TimerData

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: data.timerType))
                .font(.title2)
                .foregroundColor(timerAccentColor(for: data.timerType))

            VStack(alignment: .leading, spacing: 2) {
                Text(data.babyName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(data.label)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            Text(data.startTime, style: .timer)
                .font(.title3.monospacedDigit())
                .fontWeight(.bold)
                .foregroundColor(timerAccentColor(for: data.timerType))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Dynamic Island Expanded Views

@available(iOSApplicationExtension 16.1, *)
struct ExpandedLeadingView: View {
    let data: TimerData

    var body: some View {
        Image(systemName: iconName(for: data.timerType))
            .font(.title)
            .foregroundColor(timerAccentColor(for: data.timerType))
            .padding(.leading, 8)
    }
}

@available(iOSApplicationExtension 16.1, *)
struct ExpandedTrailingView: View {
    let data: TimerData

    var body: some View {
        Text(data.startTime, style: .timer)
            .font(.title2.monospacedDigit())
            .fontWeight(.bold)
            .foregroundColor(timerAccentColor(for: data.timerType))
            .padding(.trailing, 8)
    }
}

@available(iOSApplicationExtension 16.1, *)
struct ExpandedBottomView: View {
    let data: TimerData

    var body: some View {
        VStack(spacing: 4) {
            Text(data.label)
                .font(.subheadline)
                .fontWeight(.semibold)

            if data.totalTargetSeconds > 0 {
                ProgressView(
                    timerInterval: data.startTime...data.startTime.addingTimeInterval(Double(data.totalTargetSeconds)),
                    countsDown: false
                )
                .tint(timerAccentColor(for: data.timerType))
                .labelsHidden()
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Compact Views

@available(iOSApplicationExtension 16.1, *)
struct CompactLeadingView: View {
    let data: TimerData

    var body: some View {
        Image(systemName: iconName(for: data.timerType))
            .foregroundColor(timerAccentColor(for: data.timerType))
    }
}

@available(iOSApplicationExtension 16.1, *)
struct CompactTrailingView: View {
    let data: TimerData

    var body: some View {
        Text(data.startTime, style: .timer)
            .font(.caption.monospacedDigit())
            .fontWeight(.semibold)
            .foregroundColor(timerAccentColor(for: data.timerType))
            .frame(width: 42)
    }
}

@available(iOSApplicationExtension 16.1, *)
struct MinimalView: View {
    let data: TimerData

    var body: some View {
        Image(systemName: iconName(for: data.timerType))
            .foregroundColor(timerAccentColor(for: data.timerType))
    }
}

// MARK: - Helpers

private func iconName(for timerType: String) -> String {
    switch timerType {
    case "feeding": return "drop.fill"
    case "pump": return "bolt.fill"
    case "sleep": return "moon.fill"
    default: return "timer"
    }
}

private func timerAccentColor(for timerType: String) -> Color {
    switch timerType {
    case "feeding": return Color(red: 0.91, green: 0.51, blue: 0.66)  // blossom
    case "pump": return Color(red: 0.49, green: 0.91, blue: 0.78)     // mint
    case "sleep": return Color(red: 0.58, green: 0.48, blue: 0.87)    // lavender
    default: return .primary
    }
}

// MARK: - Widget Bundle

@available(iOSApplicationExtension 16.1, *)
@main
struct MeBeActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        MeBeActivityWidget()
    }
}

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Activity Attributes

struct MeBeActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timerType: String   // "feeding" | "pump" | "sleep"
        var elapsedSeconds: Int
        var label: String       // e.g. "Bú trái · 05:23"
        var startTime: Date
        var totalTargetSeconds: Int  // 0 means open-ended
    }

    var babyName: String
}

// MARK: - Live Activity Widget

@available(iOSApplicationExtension 16.1, *)
struct MeBeActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeBeActivityAttributes.self) { context in
            // Lock-screen / banner view
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view (long-press)
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                CompactLeadingView(context: context)
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
            .widgetURL(URL(string: "mebe://timer/\(context.attributes.babyName)"))
        }
    }
}

// MARK: - Lock Screen View

@available(iOSApplicationExtension 16.1, *)
struct LockScreenView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: context.state.timerType))
                .font(.title2)
                .foregroundColor(accentColor(for: context.state.timerType))

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.babyName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(context.state.label)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            Text(timerText(elapsed: context.state.elapsedSeconds))
                .font(.title3.monospacedDigit())
                .fontWeight(.bold)
                .foregroundColor(accentColor(for: context.state.timerType))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Dynamic Island Expanded Views

@available(iOSApplicationExtension 16.1, *)
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        Image(systemName: iconName(for: context.state.timerType))
            .font(.title)
            .foregroundColor(accentColor(for: context.state.timerType))
            .padding(.leading, 8)
    }
}

@available(iOSApplicationExtension 16.1, *)
struct ExpandedTrailingView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        Text(timerText(elapsed: context.state.elapsedSeconds))
            .font(.title2.monospacedDigit())
            .fontWeight(.bold)
            .foregroundColor(accentColor(for: context.state.timerType))
            .padding(.trailing, 8)
    }
}

@available(iOSApplicationExtension 16.1, *)
struct ExpandedBottomView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        VStack(spacing: 4) {
            Text(context.state.label)
                .font(.subheadline)
                .fontWeight(.semibold)

            if context.state.totalTargetSeconds > 0 {
                ProgressView(
                    value: Double(context.state.elapsedSeconds),
                    total: Double(context.state.totalTargetSeconds)
                )
                .tint(accentColor(for: context.state.timerType))
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Compact Views

@available(iOSApplicationExtension 16.1, *)
struct CompactLeadingView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        Image(systemName: iconName(for: context.state.timerType))
            .foregroundColor(accentColor(for: context.state.timerType))
    }
}

@available(iOSApplicationExtension 16.1, *)
struct CompactTrailingView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        Text(timerText(elapsed: context.state.elapsedSeconds))
            .font(.caption.monospacedDigit())
            .fontWeight(.semibold)
            .foregroundColor(accentColor(for: context.state.timerType))
    }
}

@available(iOSApplicationExtension 16.1, *)
struct MinimalView: View {
    let context: ActivityViewContext<MeBeActivityAttributes>

    var body: some View {
        Image(systemName: iconName(for: context.state.timerType))
            .foregroundColor(accentColor(for: context.state.timerType))
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

private func accentColor(for timerType: String) -> Color {
    switch timerType {
    case "feeding": return Color(red: 0.91, green: 0.51, blue: 0.66)  // blossom
    case "pump": return Color(red: 0.49, green: 0.91, blue: 0.78)     // mint
    case "sleep": return Color(red: 0.58, green: 0.48, blue: 0.87)    // lavender
    default: return .primary
    }
}

private func timerText(elapsed: Int) -> String {
    let h = elapsed / 3600
    let m = (elapsed % 3600) / 60
    let s = elapsed % 60
    if h > 0 {
        return String(format: "%d:%02d:%02d", h, m, s)
    }
    return String(format: "%02d:%02d", m, s)
}

// MARK: - Widget Bundle

@available(iOSApplicationExtension 16.1, *)
@main
struct MeBeActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        MeBeActivityWidget()
    }
}

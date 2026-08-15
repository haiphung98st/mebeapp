import WidgetKit
import SwiftUI

// MARK: - Data model

struct WidgetData {
    let babyName: String
    let babyAgeWeeks: Int
    let lastFeedingTime: Date?
    let lastFeedingType: String
    let nextFeedingTime: Date?
    let isSleeping: Bool
    let sleepStartTime: Date?
    let todayFeedingCount: Int
    let todaySleepMinutes: Int
    let todayDiaperCount: Int
    let todayPumpMl: Double
    let isPremium: Bool

    static var empty: WidgetData {
        WidgetData(
            babyName: "MeBé",
            babyAgeWeeks: 0,
            lastFeedingTime: nil,
            lastFeedingType: "",
            nextFeedingTime: nil,
            isSleeping: false,
            sleepStartTime: nil,
            todayFeedingCount: 0,
            todaySleepMinutes: 0,
            todayDiaperCount: 0,
            todayPumpMl: 0,
            isPremium: false
        )
    }
}

// MARK: - UserDefaults reader

private let appGroup = "group.com.mebe.mebetracker"

private func loadWidgetData() -> WidgetData {
    let defaults = UserDefaults(suiteName: appGroup)

    func date(_ key: String) -> Date? {
        guard let s = defaults?.string(forKey: key) else { return nil }
        return ISO8601DateFormatter().date(from: s)
    }

    return WidgetData(
        babyName: defaults?.string(forKey: "babyName") ?? "MeBé",
        babyAgeWeeks: defaults?.integer(forKey: "babyAgeWeeks") ?? 0,
        lastFeedingTime: date("lastFeedingTime"),
        lastFeedingType: defaults?.string(forKey: "lastFeedingType") ?? "",
        nextFeedingTime: date("nextFeedingTime"),
        isSleeping: defaults?.bool(forKey: "isSleeping") ?? false,
        sleepStartTime: date("sleepStartTime"),
        todayFeedingCount: defaults?.integer(forKey: "todayFeedingCount") ?? 0,
        todaySleepMinutes: defaults?.integer(forKey: "todaySleepMinutes") ?? 0,
        todayDiaperCount: defaults?.integer(forKey: "todayDiaperCount") ?? 0,
        todayPumpMl: defaults?.double(forKey: "todayPumpMl") ?? 0,
        isPremium: defaults?.bool(forKey: "isPremium") ?? false
    )
}

// MARK: - Timeline

struct MeBeEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct MeBeProvider: TimelineProvider {
    func placeholder(in context: Context) -> MeBeEntry {
        MeBeEntry(date: .now, data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (MeBeEntry) -> Void) {
        completion(MeBeEntry(date: .now, data: loadWidgetData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MeBeEntry>) -> Void) {
        let data = loadWidgetData()
        let entry = MeBeEntry(date: .now, data: data)
        let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

// MARK: - Helpers

private func timeAgo(_ date: Date?) -> String {
    guard let date else { return "--" }
    let mins = Int(Date().timeIntervalSince(date) / 60)
    if mins < 60 { return "\(mins) phút trước" }
    let hrs = mins / 60
    return "\(hrs) giờ trước"
}

private func feedingIcon(_ type: String) -> String {
    switch type {
    case "breastLeft", "breastRight": return "🤱"
    case "bottle": return "🍼"
    default: return "🥛"
    }
}

private func sleepDuration(from start: Date) -> String {
    let mins = Int(Date().timeIntervalSince(start) / 60)
    if mins < 60 { return "\(mins)p" }
    return "\(mins / 60)h\(mins % 60)p"
}

// MARK: - Colors / palette

private extension Color {
    static let mebeBackground  = Color(red: 1.00, green: 0.94, blue: 0.97) // #FFF0F6
    static let mebePrimary     = Color(red: 0.62, green: 0.37, blue: 0.58) // #9E5E94
    static let mebeText        = Color(red: 0.24, green: 0.10, blue: 0.21) // #3D1A35
    static let mebeSubtext     = Color(red: 0.48, green: 0.30, blue: 0.42) // #7A4D6A
    static let mebeAccentBlue  = Color(red: 0.42, green: 0.68, blue: 0.91) // #6BAEE8
    static let mebeAccentGreen = Color(red: 0.42, green: 0.76, blue: 0.60) // #6BC299
    static let mebeAccentPink  = Color(red: 0.96, green: 0.67, blue: 0.76) // #F5ABC2
}

// MARK: - Small widget (premium + free)

struct SmallWidgetView: View {
    let data: WidgetData

    var body: some View {
        if data.isPremium {
            premiumSmall
        } else {
            freeSmall
        }
    }

    private var premiumSmall: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(data.babyName.isEmpty ? "MeBé" : data.babyName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.mebeText)
                .lineLimit(1)

            if data.isSleeping {
                Label(
                    data.sleepStartTime != nil ? "Ngủ \(sleepDuration(from: data.sleepStartTime!))" : "Đang ngủ 🌙",
                    systemImage: "moon.fill"
                )
                .font(.system(size: 11))
                .foregroundColor(.mebeAccentBlue)
            } else {
                Text("🍼 Bú \(timeAgo(data.lastFeedingTime))")
                    .font(.system(size: 11))
                    .foregroundColor(.mebeSubtext)
            }

            Spacer()

            HStack {
                statPill("\(data.todayFeedingCount)", "🤱")
                statPill("\(data.todayDiaperCount)", "🌸")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.mebeBackground)
        .widgetURL(URL(string: "mebe://home"))
    }

    private var freeSmall: some View {
        VStack(spacing: 6) {
            Text("🐰").font(.system(size: 28))
            Text(data.babyName.isEmpty ? "MeBé" : data.babyName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.mebeText)
            Text("Nâng cấp Premium\nđể xem chi tiết ✨")
                .font(.system(size: 10))
                .foregroundColor(.mebeSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mebeBackground)
        .widgetURL(URL(string: "mebe://home"))
    }

    private func statPill(_ value: String, _ icon: String) -> some View {
        HStack(spacing: 2) {
            Text(icon).font(.system(size: 10))
            Text(value).font(.system(size: 11, weight: .semibold)).foregroundColor(.mebeText)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.mebePrimary.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Medium widget

struct MediumWidgetView: View {
    let data: WidgetData

    var body: some View {
        if data.isPremium {
            premiumMedium
        } else {
            freeMedium
        }
    }

    private var premiumMedium: some View {
        HStack(spacing: 0) {
            // Left: baby status
            VStack(alignment: .leading, spacing: 6) {
                Text(data.babyName.isEmpty ? "MeBé" : data.babyName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.mebeText)

                if data.isSleeping {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🌙 Đang ngủ")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.mebeAccentBlue)
                        if let start = data.sleepStartTime {
                            Text(sleepDuration(from: start))
                                .font(.system(size: 11))
                                .foregroundColor(.mebeSubtext)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(feedingIcon(data.lastFeedingType)) Bú gần nhất")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.mebeText)
                        Text(timeAgo(data.lastFeedingTime))
                            .font(.system(size: 11))
                            .foregroundColor(.mebeSubtext)
                    }
                }

                if let next = data.nextFeedingTime {
                    Text("⏰ Bú tiếp: \(timeAgo(next))")
                        .font(.system(size: 10))
                        .foregroundColor(.mebeSubtext)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 14)
            .padding(.vertical, 14)
            .widgetLink(URL(string: "mebe://feeding")!)

            Divider().padding(.vertical, 14)

            // Right: today stats
            VStack(alignment: .leading, spacing: 8) {
                statRow("🤱", "\(data.todayFeedingCount) cữ", URL(string: "mebe://feeding")!)
                statRow("🌙", sleepMinutesLabel(data.todaySleepMinutes), URL(string: "mebe://sleep")!)
                statRow("🌸", "\(data.todayDiaperCount) tã", URL(string: "mebe://diaper")!)
                if data.todayPumpMl > 0 {
                    statRow("🥛", "\(Int(data.todayPumpMl))ml", URL(string: "mebe://pumping")!)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 14)
            .padding(.vertical, 14)
        }
        .background(Color.mebeBackground)
    }

    private var freeMedium: some View {
        HStack(spacing: 16) {
            Text("🐰").font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                Text(data.babyName.isEmpty ? "MeBé" : data.babyName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mebeText)
                Text("Nâng cấp lên Premium\nđể xem đầy đủ thông tin bé ✨")
                    .font(.system(size: 11))
                    .foregroundColor(.mebeSubtext)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mebeBackground)
        .widgetURL(URL(string: "mebe://home"))
    }

    private func statRow(_ icon: String, _ label: String, _ url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 6) {
                Text(icon).font(.system(size: 13))
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.mebeText)
            }
        }
    }
}

// MARK: - Large widget

struct LargeWidgetView: View {
    let data: WidgetData

    var body: some View {
        if data.isPremium {
            premiumLarge
        } else {
            freeLarge
        }
    }

    private var premiumLarge: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("🐰 \(data.babyName.isEmpty ? "MeBé" : data.babyName)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.mebeText)
                Spacer()
                Text("\(data.babyAgeWeeks) tuần")
                    .font(.system(size: 12))
                    .foregroundColor(.mebeSubtext)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            // Status row
            HStack(spacing: 12) {
                if data.isSleeping {
                    statusCard(
                        icon: "🌙",
                        title: "Đang ngủ",
                        subtitle: data.sleepStartTime != nil ? sleepDuration(from: data.sleepStartTime!) : "",
                        color: .mebeAccentBlue,
                        url: URL(string: "mebe://sleep")!
                    )
                } else {
                    statusCard(
                        icon: feedingIcon(data.lastFeedingType),
                        title: "Bú gần nhất",
                        subtitle: timeAgo(data.lastFeedingTime),
                        color: .mebeAccentPink,
                        url: URL(string: "mebe://feeding")!
                    )
                }
                if let next = data.nextFeedingTime {
                    statusCard(
                        icon: "⏰",
                        title: "Bú tiếp",
                        subtitle: timeAgo(next),
                        color: .mebePrimary,
                        url: URL(string: "mebe://feeding")!
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Today summary grid
            Text("HÔM NAY")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.mebeSubtext)
                .tracking(1.2)
                .padding(.horizontal, 16)
                .padding(.top, 10)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                bigStatCard("🤱", "Bú", "\(data.todayFeedingCount) cữ", .mebeAccentPink, URL(string: "mebe://feeding")!)
                bigStatCard("🌙", "Ngủ", sleepMinutesLabel(data.todaySleepMinutes), .mebeAccentBlue, URL(string: "mebe://sleep")!)
                bigStatCard("🌸", "Thay tã", "\(data.todayDiaperCount) lần", .mebeAccentGreen, URL(string: "mebe://diaper")!)
                bigStatCard("🥛", "Hút sữa", data.todayPumpMl > 0 ? "\(Int(data.todayPumpMl))ml" : "--", .mebePrimary, URL(string: "mebe://pumping")!)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.mebeBackground)
    }

    private var freeLarge: some View {
        VStack(spacing: 16) {
            Text("🐰").font(.system(size: 48))
            Text(data.babyName.isEmpty ? "MeBé" : data.babyName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.mebeText)
            Text("Nâng cấp lên Premium để theo dõi\nbé yêu trực tiếp từ màn hình chính ✨")
                .font(.system(size: 13))
                .foregroundColor(.mebeSubtext)
                .multilineTextAlignment(.center)
            Text("Mở ứng dụng →")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.mebePrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mebeBackground)
        .widgetURL(URL(string: "mebe://home"))
    }

    private func statusCard(icon: String, title: String, subtitle: String, color: Color, url: URL) -> some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: 4) {
                Text(icon).font(.system(size: 20))
                Text(title).font(.system(size: 11)).foregroundColor(.mebeSubtext)
                Text(subtitle).font(.system(size: 13, weight: .semibold)).foregroundColor(color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func bigStatCard(_ icon: String, _ label: String, _ value: String, _ color: Color, _ url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 8) {
                Text(icon).font(.system(size: 18))
                VStack(alignment: .leading, spacing: 1) {
                    Text(label).font(.system(size: 10)).foregroundColor(.mebeSubtext)
                    Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(color)
                }
                Spacer()
            }
            .padding(10)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Lock Screen widget (accessoryRectangular)

struct LockScreenWidgetView: View {
    let data: WidgetData

    var body: some View {
        if data.isSleeping {
            Label("Ngủ \(data.sleepStartTime != nil ? sleepDuration(from: data.sleepStartTime!) : "")", systemImage: "moon.fill")
                .font(.system(size: 13, weight: .semibold))
                .widgetURL(URL(string: "mebe://sleep"))
        } else {
            HStack(spacing: 12) {
                Label("\(data.todayFeedingCount)", systemImage: "drop.fill")
                Label("\(data.todayDiaperCount)", systemImage: "star.fill")
                if data.todayPumpMl > 0 {
                    Label("\(Int(data.todayPumpMl))ml", systemImage: "cross.fill")
                }
            }
            .font(.system(size: 12))
            .widgetURL(URL(string: "mebe://home"))
        }
    }
}

// MARK: - Main widget

private func sleepMinutesLabel(_ minutes: Int) -> String {
    if minutes == 0 { return "--" }
    if minutes < 60 { return "\(minutes)p" }
    return "\(minutes / 60)h\(minutes % 60 > 0 ? "\(minutes % 60)p" : "")"
}

struct MeBeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MeBeEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .systemLarge:
            LargeWidgetView(data: entry.data)
        case .accessoryRectangular:
            LockScreenWidgetView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

@main
struct MeBeWidget: Widget {
    let kind = "MeBeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MeBeProvider()) { entry in
            MeBeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MeBé Tracker")
        .description("Theo dõi bé yêu ngay trên màn hình chính.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

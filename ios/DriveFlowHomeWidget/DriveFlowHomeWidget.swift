import SwiftUI
import WidgetKit

private let appGroupId = "group.com.driveflow.driveflow"

struct DriveFlowEntry: TimelineEntry {
    let date: Date
    let profit: String
    let revenue: String
    let shiftActive: Bool
    let shiftRevenue: String
    let shiftElapsed: String
}

struct DriveFlowProvider: TimelineProvider {
    func placeholder(in context: Context) -> DriveFlowEntry {
        DriveFlowEntry(
            date: Date(),
            profit: "R$ 0,00",
            revenue: "R$ 0,00",
            shiftActive: false,
            shiftRevenue: "",
            shiftElapsed: ""
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DriveFlowEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DriveFlowEntry>) -> Void) {
        let entry = readEntry()
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private func readEntry() -> DriveFlowEntry {
        let prefs = UserDefaults(suiteName: appGroupId)
        return DriveFlowEntry(
            date: Date(),
            profit: prefs?.string(forKey: "today_profit") ?? "R$ 0,00",
            revenue: prefs?.string(forKey: "today_revenue") ?? "R$ 0,00",
            shiftActive: prefs?.bool(forKey: "shift_active") ?? false,
            shiftRevenue: prefs?.string(forKey: "shift_revenue") ?? "",
            shiftElapsed: prefs?.string(forKey: "shift_elapsed") ?? ""
        )
    }
}

struct DriveFlowHomeWidgetEntryView: View {
    var entry: DriveFlowProvider.Entry

    var body: some View {
        let headline = entry.shiftActive && !entry.shiftRevenue.isEmpty
            ? entry.shiftRevenue
            : entry.profit
        let title = entry.shiftActive ? "Turno ativo" : "Lucro hoje"
        let subtitle: String = {
            if entry.shiftActive && !entry.shiftRevenue.isEmpty {
                return "Turno \(entry.shiftElapsed) · \(entry.shiftRevenue)"
            }
            return "Ganhos \(entry.revenue) · Toque para abrir"
        }()

        ZStack(alignment: .leading) {
            Color(red: 0, green: 0.392, blue: 0.961)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Text(headline)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            .padding(16)
        }
    }
}

struct DriveFlowHomeWidget: Widget {
    let kind: String = "DriveFlowHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DriveFlowProvider()) { entry in
            DriveFlowHomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("DriveFlow")
        .description("Lucro de hoje e turno ativo.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct DriveFlowHomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        DriveFlowHomeWidget()
    }
}

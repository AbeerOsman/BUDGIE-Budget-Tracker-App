//
//  BudgieWidget.swift
//  BudgieWidget
//
//  Created by Ruba Alghamdi on 07/12/1447 AH.
//


import WidgetKit
import SwiftUI

// MARK: - ENTRY

struct BudgetEntry: TimelineEntry {
    let date: Date
    let spent: Double
    let budget: Double
}

// MARK: - PROVIDER

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> BudgetEntry {
        BudgetEntry(
            date: .now,
            spent: 33.04,
            budget: 77
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (BudgetEntry) -> Void
    ) {

        let defaults = UserDefaults(
            suiteName: "group.com.raghad.BUDGIE"
        )

        let spent =
        defaults?.double(
            forKey: "widget_spent_today"
        ) ?? 0

        let budget =
        defaults?.double(
            forKey: "widget_daily_budget"
        ) ?? 0

        completion(
            BudgetEntry(
                date: .now,
                spent: spent,
                budget: budget
            )
        )
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<BudgetEntry>) -> Void
    ) {

        let defaults = UserDefaults(
            suiteName: "group.com.raghad.BUDGIE"
        )

        let spent =
        defaults?.double(
            forKey: "widget_spent_today"
        ) ?? 0

        let budget =
        defaults?.double(
            forKey: "widget_daily_budget"
        ) ?? 0

        let entry = BudgetEntry(
            date: .now,
            spent: spent,
            budget: budget
        )

        let timeline = Timeline(
            entries: [entry],
            policy: .after(
                .now.addingTimeInterval(3600)
            )
        )

        completion(timeline)
    }
} // <-- Close Provider

// MARK: - MAIN VIEW

struct BudgetWidgetView: View {

    @Environment(\.widgetFamily) var family

    let entry: BudgetEntry

    var progress: Double {
        guard entry.budget > 0 else { return 0 }
            return min(entry.spent / entry.budget, 1)
    }

    var body: some View {

        switch family {

        case .accessoryCircular:
            CircularWidget(progress: progress)

        case .accessoryRectangular:
            RectangularWidget(
                entry: entry,
                progress: progress
            )

        default:
            RectangularWidget(
                entry: entry,
                progress: progress
            )
        }
    }
}

// MARK: - WIDGET CURRENCY

private struct WidgetCurrencyAmount: View {
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .foregroundStyle(color)

            Image("SAR")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 11, height: 11)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - CIRCULAR LOCK SCREEN

struct CircularWidget: View {

    let progress: Double

    var body: some View {

        ZStack {

            Circle()
                .stroke(
                    Color.gray.opacity(0.45),
                    lineWidth: 5
                )

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.cyan,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Image("favicon")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
        .padding(4)

        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - RECTANGULAR LOCK SCREEN

struct RectangularWidget: View {

    let entry: BudgetEntry
    let progress: Double

    var body: some View {

        HStack(spacing: 10) {

            ZStack {

                Circle()
                    .stroke(
                        Color.gray.opacity(0.45),
                        lineWidth: 5
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.cyan,
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                Image("favicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)

            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 1) {

                Text("Spent")
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 2) {
                    WidgetCurrencyAmount(
                        value: Int(entry.spent),
                        color: .cyan
                    )

                    Text("/")
                        .foregroundColor(.gray)

                    WidgetCurrencyAmount(
                        value: Int(entry.budget),
                        color: .gray
                    )
                }
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 4)

        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - WIDGET

struct BudgetWidget: Widget {

    let kind = "BudgetWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in

            BudgetWidgetView(entry: entry)
        }
        .configurationDisplayName("Budget Widget")
        .description("Track your spending progress.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

// MARK: - PREVIEWS

#Preview(as: .accessoryCircular) {

    BudgetWidget()

} timeline: {

    BudgetEntry(
        date: .now,
        spent: 33.04,
        budget: 77
    )
}

#Preview(as: .accessoryRectangular) {

    BudgetWidget()

} timeline: {

    BudgetEntry(
        date: .now,
        spent: 33.04,
        budget: 77
    )
}

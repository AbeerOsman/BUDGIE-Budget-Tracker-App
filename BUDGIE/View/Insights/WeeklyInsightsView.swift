//
//  WeeklyInsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 05/12/1447 AH.
//
import SwiftUI
import Charts


struct WeeklySpendingPoint: Identifiable {
    var id: String { dayName }

    let date: Date
    let dayName: String
    let amount: Double
}

struct WeeklyInsightsView: View {

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.colorScheme) private var colorScheme

    let totalIncome: Double

    @State private var selectedPoint: WeeklySpendingPoint?

    private var dailyBudget: Double {
        let categoryDailyLimits = categoriesViewModel.spendingCategories
            .compactMap { $0.dailyLimit }
            .reduce(0, +)

        if categoryDailyLimits > 0 {
            return categoryDailyLimits
        }

        return totalIncome > 0 ? totalIncome / 30 : 0
    }

    private var weeklyData: [WeeklySpendingPoint] {
        let calendar = Calendar.current
        let today = Date()

        let dates = (0..<7).compactMap { index in
            calendar.date(byAdding: .day, value: -6 + index, to: today)
        }

        let allPayments = categoriesViewModel.paymentsByCategoryId.values
            .flatMap { $0 }

        return dates.map { date in
            let total = allPayments
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }

            return WeeklySpendingPoint(
                date: date,
                dayName: date.formatted(.dateTime.weekday(.abbreviated)),
                amount: total
            )
        }
    }

    private var maxChartValue: Double {
        max(
            weeklyData.map(\.amount).max() ?? 0,
            dailyBudget,
            1
        )
    }

    private var gridLineColor: Color {
        Color.gray.opacity(0.35)
    }

    private var selectedLineColor: Color {
        Color.gray.opacity(0.55)
    }

    private var axisTextColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.55)
            : Color.black.opacity(0.55)
    }

    var body: some View {
        Chart {
            ForEach(weeklyData) { point in

                BarMark(
                    x: .value("Day", point.dayName),
                    y: .value("Spent", point.amount)
                )
                .foregroundStyle(Color(hex: "#3FAFD3"))
                .cornerRadius(3)

                if dailyBudget > 0 {
                    RuleMark(y: .value("Daily Limit", dailyBudget))
                        .foregroundStyle(gridLineColor)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .annotation(position: .trailing) {
                            Text("$ \(Int(dailyBudget))")
                                .font(.system(size: 12))
                                .foregroundStyle(axisTextColor)
                        }
                }

                if let selectedPoint,
                   selectedPoint.dayName == point.dayName {

                    RuleMark(x: .value("Selected", point.dayName))
                        .foregroundStyle(selectedLineColor)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .annotation(
                            position: .top,
                            alignment: .center,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(point.dayName.uppercased())
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)

                                Text("$\(point.amount, specifier: "%.0f")")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)

                                Text(point.date.formatted(.dateTime.day().month(.abbreviated).year()))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        colorScheme == .dark
                                            ? Color.white.opacity(0.16)
                                            : Color.black.opacity(0.16)
                                    )
                            )
                        }
                }
            }
        }
        .chartYScale(domain: 0...(maxChartValue * 1.25))
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
                    .foregroundStyle(gridLineColor)

                AxisValueLabel()
                    .foregroundStyle(axisTextColor)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { _ in
                AxisGridLine()
                    .foregroundStyle(gridLineColor)

                AxisValueLabel()
                    .foregroundStyle(axisTextColor)
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard let plotFrame = proxy.plotFrame else { return }

                                let origin = geometry[plotFrame].origin
                                let locationX = value.location.x - origin.x

                                if let day: String = proxy.value(
                                    atX: locationX,
                                    as: String.self
                                ) {
                                    selectedPoint = weeklyData.first {
                                        $0.dayName == day
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedPoint = nil
                            }
                    )
            }
        }
        .frame(height: 240)
        .padding(.top, 16)
    }
}

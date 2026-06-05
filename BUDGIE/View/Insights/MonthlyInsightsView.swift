//
//  MonthlyInsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 06/12/1447 AH.
//

import SwiftUI
import Charts

struct MonthlySpendingPoint: Identifiable {
    var id: String { monthName }

    let monthName: String
    let amount: Double
}

struct MonthlyInsightsView: View {

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedPoint: MonthlySpendingPoint?

    private var allPayments: [CategoryPayment] {
        let spendingCategoryIds = Set(
            categoriesViewModel.spendingCategories.map { $0.id }
        )

        return categoriesViewModel.paymentsByCategoryId
            .filter { spendingCategoryIds.contains($0.key) }
            .values
            .flatMap { $0 }
    }

    private var monthlyData: [MonthlySpendingPoint] {

        let calendar = Calendar.current

        let months = (0..<6).compactMap { index in
            calendar.date(byAdding: .month, value: -5 + index, to: Date())
        }

        return months.map { monthDate in

            let total = allPayments
                .filter {
                    calendar.isDate(
                        $0.date,
                        equalTo: monthDate,
                        toGranularity: .month
                    )
                }
                .reduce(0) { $0 + $1.amount }

            return MonthlySpendingPoint(
                monthName: monthDate.formatted(
                    .dateTime.month(.abbreviated)
                ),
                amount: total
            )
        }
    }

    private var maxChartValue: Double {
        max(
            monthlyData.map(\.amount).max() ?? 0,
            1
        )
    }

    private var gridLineColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.10)
            : Color.black.opacity(0.10)
    }

    private var axisTextColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.55)
            : Color.black.opacity(0.55)
    }

    var body: some View {

        Chart {

            ForEach(monthlyData) { point in

                BarMark(
                    x: .value("Month", point.monthName),
                    y: .value(String(localized: "Spent"), point.amount)
                )
                .foregroundStyle(Color(hex: "#3FAFD3"))
                .cornerRadius(3)

                if let selectedPoint,
                   selectedPoint.monthName == point.monthName {

                    RuleMark(
                        x: .value(String(localized: "Selected"), point.monthName),
                        yStart: .value("Line Start", point.amount + 10),
                        yEnd: .value("Line End", maxChartValue * 0.68)
                    )
                    .foregroundStyle(Color(hex: "#3FAFD3"))
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: 2,
                            lineCap: .round
                        )
                    )
                    .annotation(
                        position: .top,
                        alignment: .center
                    ) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(point.monthName.uppercased())
                                .font(BudgieFont.caption)
                                .foregroundStyle(.secondary)

                            CurrencyAmountDoubleView(
                                amount: point.amount,
                                font: BudgieFont.title3,
                                iconSize: 16,
                                tint: .white
                            )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    colorScheme == .dark
                                    ? Color.white.opacity(0.18)
                                    : Color.black.opacity(0.16)
                                )
                        )
                        .offset(y: 10)
                    }
                }
            }
        }
        .chartYScale(domain: 0...(maxChartValue * 1.2))
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

                                if let month: String = proxy.value(
                                    atX: locationX,
                                    as: String.self
                                ) {
                                    selectedPoint = monthlyData.first {
                                        $0.monthName == month
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

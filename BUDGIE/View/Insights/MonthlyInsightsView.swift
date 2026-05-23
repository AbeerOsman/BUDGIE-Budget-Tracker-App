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

    private var allPayments: [CategoryPayment] {
        categoriesViewModel.paymentsByCategoryId.values
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
                    y: .value("Spent", point.amount)
                )
                .foregroundStyle(Color(hex: "#3FAFD3"))
                .cornerRadius(3)
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
        .frame(height: 240)
        .padding(.top, 16)
    }
}



//
//  InsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 01/12/1447 AH.
//
import SwiftUI

struct InsightsView: View {
    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.colorScheme) private var colorScheme

    let totalIncome: Double

    @State private var viewModel = InsightsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Insights")
                .font(BudgieFont.title2)
                .tracking(-0.26)
                .foregroundColor(.primary)
                .padding(.top, 2)

            if viewModel.hasInsights(
                categoriesViewModel: categoriesViewModel,
                totalIncome: totalIncome
            ) {

                InsightsPeriodPicker(selected: $viewModel.selectedPeriod)

                switch viewModel.selectedPeriod {
                case .day:
                    DailyInsightsView(totalIncome: totalIncome)

                case .week:
                    WeeklyInsightsView(totalIncome: totalIncome)

                case .month:
                    MonthlyInsightsView()
                }

            } else {
                Spacer()
                InsightsEmptyState()
                Spacer()
            }
        }
        .padding(16)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    colorScheme == .dark
                    ? Color("Dark Charcoal")
                    : Color.budgieGroupedBoxBackground(for: colorScheme)
                )
        )
    }
}
#Preview {

    let categoriesViewModel = CategoriesViewModel()

    let foodCategory = Category(
        emoji: "🍔",
        name: "Food",
        type: .spending,
        spent: 0,
        budget: 300,
        dailyLimit: 77,
        colorIndex: 0
    )

    categoriesViewModel.add(foodCategory)

    categoriesViewModel.addPayment(
        CategoryPayment(
            categoryId: foodCategory.id,
            merchantName: "McDonalds",
            date: Date(),
            amount: 33.04
        ),
        to: foodCategory.id
    )

    return ZStack {

        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 0.0, green: 0.6, blue: 0.8),
                    Color(red: 0.0, green: 0.2, blue: 0.6),
                    Color(red: 0.4, green: 0.1, blue: 0.4)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        InsightsView(totalIncome: 5000)
            .padding()
    }
    .environment(categoriesViewModel)
}

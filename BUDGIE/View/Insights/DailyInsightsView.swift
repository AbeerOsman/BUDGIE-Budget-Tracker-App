//
//  DailyInsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 04/12/1447 AH.
//
import SwiftUI

struct DailyInsightsView: View {

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    let totalIncome: Double

    @State private var viewModel = DailyInsightViewModel()

    var body: some View {
        HStack(spacing: 18) {

            DailyProgressCircle(progress: viewModel.progress)
                .frame(width: 118, height: 130)

            VStack(alignment: .leading, spacing: 4) {

                Text("Spent from budget")
                    .font(BudgieFont.subheadline)
                    .foregroundStyle(.primary)

                CurrencyRatioView(
                    leading: Int(viewModel.totalSpentToday),
                    trailing: Int(viewModel.dailyBudget),
                    font: BudgieFont.title3,
                    iconSize: 14,
                    tint: Color(hex: "#3FAFD3")
                )
                .foregroundStyle(Color(hex: "#3FAFD3"))
            }
            .offset(y: -10)

            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            refresh()
        }
        .onChange(of: totalIncome) { _, _ in
            refresh()
        }
    }

    private func refresh() {
        viewModel.update(
            categoriesViewModel: categoriesViewModel,
            totalIncome: totalIncome
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

        Color.black
            .ignoresSafeArea()

        DailyInsightsView(
            totalIncome: 5000
        )
        .padding()
    }
    .environment(categoriesViewModel)
}

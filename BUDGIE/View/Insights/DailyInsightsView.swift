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
        .onChange(of: categoriesViewModel.categories) { _, _ in
            refresh()
        }
        .onChange(of: categoriesViewModel.paymentsByCategoryId) { _, _ in
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

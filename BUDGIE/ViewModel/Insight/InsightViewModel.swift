//
//  InsightViewModel.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 01/12/1447 AH.
//
import Foundation
import Observation

enum InsightsPeriod {
    case day, week, month
}

@Observable
final class InsightsViewModel {

    var selectedPeriod: InsightsPeriod = .day

    func hasInsights(
        categoriesViewModel: CategoriesViewModel,
        totalIncome: Double
    ) -> Bool {
        let hasIncome = totalIncome > 0
        let hasBudget = categoriesViewModel.spendingCategories.contains {
            $0.budget > 0 || ($0.dailyLimit ?? 0) > 0
        }
        let spendingCategoryIds = Set(
            categoriesViewModel.spendingCategories.map { $0.id }
        )

        let hasPayments = categoriesViewModel.paymentsByCategoryId.contains {
            spendingCategoryIds.contains($0.key) && !$0.value.isEmpty
        }

        return hasIncome && hasBudget && hasPayments
    }
}

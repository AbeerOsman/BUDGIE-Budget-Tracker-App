//
//  DailyInsightViewModel.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

/**
 يعرض:
 chart حق 24 ساعة
 total spent today
 remaining today
 */
import Foundation
import Observation
import SwiftUI

@Observable
final class DailyInsightViewModel {

    var totalSpentToday: Double = 0
    var dailyBudget: Double = 0

    var remainingToday: Double {
        max(dailyBudget - totalSpentToday, 0)
    }

    var progress: CGFloat {
        guard dailyBudget > 0 else { return 0 }
        return CGFloat(min(totalSpentToday / dailyBudget, 1))
    }

    var hasUsableData: Bool {
        dailyBudget > 0
    }

    func update(
        categoriesViewModel: CategoriesViewModel,
        totalIncome: Double,
        calendar: Calendar = .current
    ) {
        let todayPayments = categoriesViewModel.paymentsByCategoryId.values
            .flatMap { $0 }
            .filter { calendar.isDateInToday($0.date) }

        totalSpentToday = todayPayments.reduce(0) { $0 + $1.amount }

        let categoryDailyLimits = categoriesViewModel.spendingCategories
            .compactMap { $0.dailyLimit }
            .reduce(0, +)

        if categoryDailyLimits > 0 {
            dailyBudget = categoryDailyLimits
        } else {
            dailyBudget = totalIncome > 0 ? totalIncome / 30 : 0
        }

        // 👇 ربط الودجت
        WidgetBudgetStore.save(
            spentToday: totalSpentToday,
            dailyBudget: dailyBudget
        )
    }
}

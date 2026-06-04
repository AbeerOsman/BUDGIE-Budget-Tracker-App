//
//  WidgetBudgetStore.swift
//  BudgieWidget
//

import Foundation
import WidgetKit

enum WidgetBudgetStore {
    /// Must match BUDGIE/Services/WidgetBudgetStore.swift and App Group entitlements.
    static let suiteName = "group.com.raghad.BUDGIE"

    private static let spentKey = "widget_spent_today"
    private static let budgetKey = "widget_daily_budget"

    static func read() -> (spent: Double, budget: Double) {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return (0, 0)
        }

        return (
            defaults.double(forKey: spentKey),
            defaults.double(forKey: budgetKey)
        )
    }
}

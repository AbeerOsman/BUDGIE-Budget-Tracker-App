//
//  WidgetBudgetStore.swift
//  BUDGIE
//
//  Shared values for the lock-screen widget.
//

import Foundation
import WidgetKit

enum WidgetBudgetStore {
    /// Must match BudgieWidget/WidgetBudgetStore.swift and App Group entitlements.
    static let suiteName = "group.com.Challenge7Team16.BUDGIE--Money-Tracker-App.BudgieWidget"

    private static let spentKey = "widget_spent_today"
    private static let budgetKey = "widget_daily_budget"

    static func save(spentToday: Double, dailyBudget: Double) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(spentToday, forKey: spentKey)
        defaults.set(dailyBudget, forKey: budgetKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "BudgetWidget")
    }
}

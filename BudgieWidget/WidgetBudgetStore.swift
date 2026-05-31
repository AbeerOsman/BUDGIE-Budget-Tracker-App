//
//  WidgetBudgetStore.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 08/12/1447 AH.
//
import Foundation
import WidgetKit

enum WidgetBudgetStore {
    static let suiteName = "group.com.Challenge7Team16.BUDGIE--Money-Tracker-App"

    private static let spentKey = "widget_spent_today"
    private static let budgetKey = "widget_daily_budget"

    static func save(spentToday: Double, dailyBudget: Double) {
        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set(spentToday, forKey: spentKey)
        defaults?.set(dailyBudget, forKey: budgetKey)
        defaults?.synchronize()

        let savedSpent = defaults?.double(forKey: spentKey) ?? -1
        let savedBudget = defaults?.double(forKey: budgetKey) ?? -1

        print("Saved widget data:", savedSpent, savedBudget)

        WidgetCenter.shared.reloadAllTimelines()
    }
    static func read() -> (spent: Double, budget: Double) {
        let defaults = UserDefaults(suiteName: suiteName)

        return (
            defaults?.double(forKey: spentKey) ?? 0,
            defaults?.double(forKey: budgetKey) ?? 0
        )
    }
}

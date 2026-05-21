//
//  BudgieNotificationService.swift
//  BUDGIE
//

import Foundation
import UserNotifications

final class BudgieNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = BudgieNotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

final class BudgieNotificationService {
    static let shared = BudgieNotificationService()

    private let center = UNUserNotificationCenter.current()
    private let incomeExceededKey = "budgie.notifications.incomeExceeded"
    private let categoryExceededPrefix = "budgie.notifications.categoryExceeded."

    private init() {}

    // MARK: - Permission

    func requestAuthorizationIfNeeded() {
        center.delegate = BudgieNotificationDelegate.shared
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification authorization error:", error)
            } else if !granted {
                print("Notification permission not granted")
            }
        }
    }

    // MARK: - Transaction notifications

    func notifyExpenseTracked(
        merchant: String,
        amount: Double,
        categoryName: String
    ) {
        let body = "\(formatCurrency(amount)) from \(merchant) was added to \(categoryName)."
        schedule(
            title: "Expense Tracked!",
            body: body,
            identifier: "expense.tracked.\(UUID().uuidString)"
        )
    }

    func notifyNeedsFilter(
        merchant: String,
        amount: Double?
    ) {
        let amountPart: String
        if let amount {
            amountPart = "A \(formatCurrency(amount)) payment from \(merchant)"
        } else {
            amountPart = "A payment from \(merchant)"
        }

        let body = "\(amountPart) needs a category. Open Filter to assign it."
        schedule(
            title: "Transaction Needs Filter",
            body: body,
            identifier: "expense.filter.\(UUID().uuidString)"
        )
    }

    // MARK: - Budget notifications

    func checkCategoryBudgetExceeded(
        categoryId: UUID,
        categoryName: String,
        budget: Double,
        previousSpent: Double,
        currentSpent: Double
    ) {
        guard budget > 0 else { return }
        guard previousSpent < budget, currentSpent >= budget else { return }

        let key = categoryExceededPrefix + categoryId.uuidString
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        UserDefaults.standard.set(true, forKey: key)

        let body = "You've reached your \(formatCurrency(budget)) budget for \(categoryName)."
        schedule(
            title: "Category Budget Exceeded",
            body: body,
            identifier: "budget.category.\(categoryId.uuidString)"
        )
    }

    func evaluateIncomeBudgetIfNeeded(
        totalIncome: Double,
        previousTotalSpent: Double,
        currentTotalSpent: Double
    ) {
        guard totalIncome > 0 else { return }

        if currentTotalSpent < totalIncome {
            UserDefaults.standard.set(false, forKey: incomeExceededKey)
            return
        }

        guard previousTotalSpent < totalIncome, currentTotalSpent >= totalIncome else { return }
        guard !UserDefaults.standard.bool(forKey: incomeExceededKey) else { return }

        UserDefaults.standard.set(true, forKey: incomeExceededKey)

        let body = "Total spending (\(formatCurrency(currentTotalSpent))) has reached your income (\(formatCurrency(totalIncome)))."
        schedule(
            title: "Income Budget Exceeded",
            body: body,
            identifier: "budget.income.exceeded"
        )
    }

    func clearCategoryExceededFlags() {
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(categoryExceededPrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    func clearCategoryExceededFlag(categoryId: UUID) {
        UserDefaults.standard.removeObject(
            forKey: categoryExceededPrefix + categoryId.uuidString
        )
    }

    // MARK: - Private

    private func schedule(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Failed to schedule notification:", error)
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f SAR", value)
        }
        return String(format: "%.2f SAR", value)
    }
}

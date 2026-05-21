//
//  CategoriesViewModel.swift
//  BUDGIE
//

import Foundation
import Observation
import SwiftUI

@Observable
final class CategoriesViewModel {

    var categories: [Category] = []

    var paymentsByCategoryId: [UUID: [CategoryPayment]] = [:]

    var selectedType: CategoryType = .spending

    // SMS transactions that could not be categorized
    var uncategorizedTransactions: [ParsedTransaction] = []

    // Prevent importing same SMS twice
    var importedTransactionIds: Set<UUID> = []

    /// Reset prompt handling for the current calendar month (`year-month`).
    var lastConfirmedCategoryResetPeriod: String?
    var lastDeclinedCategoryResetPeriod: String?

    /// Used for income-wide budget notifications (set from ContentView).
    var budgetAlertTotalIncome: Double = 0

    init() {
        if let state = CategoriesPersistence.load() {
            CategoriesPersistence.apply(state, to: self)
        }
    }

    private func persist() {
        CategoriesPersistence.save(from: self)
    }

    var isEmpty: Bool {
        categories.isEmpty
    }

    var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }
    }

    var spendingCategories: [Category] {
        categories.filter { $0.type == .spending }
    }

    var isSpendingEmpty: Bool {
        spendingCategories.isEmpty
    }

    /// Total spent from category payments (manual + SMS), rolled up on each category's `spent`.
    var totalSpentFromPayments: Double {
        categories.reduce(0) { $0 + $1.spent }
    }

    var hasCategoryPaymentHistory: Bool {
        totalSpentFromPayments > 0
            || paymentsByCategoryId.values.contains { !$0.isEmpty }
    }

    // MARK: - Monthly payment reset (linked to income date)

    func shouldPromptForCategoryReset(incomeDate: Date, today: Date = Date()) -> Bool {
        guard CategoryPaymentResetScheduler.isResetDayToday(
            incomeDate: incomeDate,
            today: today
        ) else {
            return false
        }

        let period = CategoryPaymentResetScheduler.periodIdentifier(for: today)
        if lastConfirmedCategoryResetPeriod == period { return false }
        if lastDeclinedCategoryResetPeriod == period { return false }
        return true
    }

    func markCategoryResetDeclined(for date: Date = Date()) {
        lastDeclinedCategoryResetPeriod = CategoryPaymentResetScheduler.periodIdentifier(for: date)
        persist()
    }

    func markCategoryResetConfirmed(for date: Date = Date()) {
        lastConfirmedCategoryResetPeriod = CategoryPaymentResetScheduler.periodIdentifier(for: date)
        persist()
    }

    func resetAllCategoryPayments() {
        BudgieNotificationService.shared.clearCategoryExceededFlags()
        paymentsByCategoryId = [:]
        categories = categories.map { category in
            Category(
                id: category.id,
                emoji: category.emoji,
                name: category.name,
                type: category.type,
                spent: 0,
                budget: category.budget,
                dailyLimit: category.dailyLimit,
                colorIndex: category.colorIndex,
                predefinedKey: category.predefinedKey
            )
        }
        persist()
    }

    func nextColorIndex(for type: CategoryType) -> Int {
        let count = categories.filter { $0.type == type }.count
        return CategoryStyling.colorIndex(for: count)
    }

    // MARK: - Budget vs income

    func totalCategoryBudget(excludingCategoryId: UUID? = nil) -> Double {
        categories
            .filter { excludingCategoryId == nil || $0.id != excludingCategoryId }
            .reduce(0) { $0 + $1.budget }
    }

    func remainingBudgetCapacity(
        totalIncome: Double,
        excludingCategoryId: UUID? = nil
    ) -> Double {
        max(0, totalIncome - totalCategoryBudget(excludingCategoryId: excludingCategoryId))
    }

    func wouldExceedIncome(
        proposedBudget: Double,
        totalIncome: Double,
        excludingCategoryId: UUID? = nil
    ) -> Bool {
        guard proposedBudget > 0 else { return false }
        if totalIncome <= 0 { return true }
        let total = totalCategoryBudget(excludingCategoryId: excludingCategoryId) + proposedBudget
        return total > totalIncome
    }

    func add(_ category: Category) {
        categories.append(category)
        persist()
    }

    func update(_ category: Category) {
        guard let index = categories.firstIndex(where: {
            $0.id == category.id
        }) else {
            return
        }

        categories[index] = category
        persist()
    }

    func delete(id: UUID) {
        categories.removeAll { $0.id == id }
        var paymentsCopy = paymentsByCategoryId
        paymentsCopy.removeValue(forKey: id)
        paymentsByCategoryId = paymentsCopy
        persist()
    }

    // MARK: - Add Payment

    func addPayment(
        _ payment: CategoryPayment,
        to categoryId: UUID
    ) {

        guard let index = categories.firstIndex(where: {
            $0.id == categoryId
        }) else {
            return
        }

        let category = categories[index]
        let previousCategorySpent = category.spent
        let previousTotalSpent = totalSpentFromPayments

        var paymentsCopy = paymentsByCategoryId
        var list = paymentsCopy[categoryId] ?? []
        list.insert(payment, at: 0)
        paymentsCopy[categoryId] = list
        paymentsByCategoryId = paymentsCopy

        // Update category spent amount
        let updatedCategory = Category(
            id: category.id,
            emoji: category.emoji,
            name: category.name,
            type: category.type,
            spent: category.spent + payment.amount,
            budget: category.budget,
            dailyLimit: category.dailyLimit,
            colorIndex: category.colorIndex,
            predefinedKey: category.predefinedKey
        )

        categories[index] = updatedCategory
        persist()

        BudgieNotificationService.shared.checkCategoryBudgetExceeded(
            categoryId: updatedCategory.id,
            categoryName: updatedCategory.name,
            budget: updatedCategory.budget,
            previousSpent: previousCategorySpent,
            currentSpent: updatedCategory.spent
        )

        BudgieNotificationService.shared.evaluateIncomeBudgetIfNeeded(
            totalIncome: budgetAlertTotalIncome,
            previousTotalSpent: previousTotalSpent,
            currentTotalSpent: totalSpentFromPayments
        )
    }

    func deletePayment(id paymentId: UUID, categoryId: UUID) {
        guard let categoryIndex = categories.firstIndex(where: {
            $0.id == categoryId
        }) else {
            return
        }

        var paymentsCopy = paymentsByCategoryId
        guard var list = paymentsCopy[categoryId] else {
            return
        }

        guard let paymentIndex = list.firstIndex(where: {
            $0.id == paymentId
        }) else {
            return
        }

        let removed = list.remove(at: paymentIndex)
        paymentsCopy[categoryId] = list
        paymentsByCategoryId = paymentsCopy

        let category = categories[categoryIndex]
        let newSpent = max(0, category.spent - removed.amount)
        categories[categoryIndex] = Category(
            id: category.id,
            emoji: category.emoji,
            name: category.name,
            type: category.type,
            spent: newSpent,
            budget: category.budget,
            dailyLimit: category.dailyLimit,
            colorIndex: category.colorIndex,
            predefinedKey: category.predefinedKey
        )
        if category.budget > 0, newSpent < category.budget {
            BudgieNotificationService.shared.clearCategoryExceededFlag(categoryId: categoryId)
        }
        persist()
    }

    func updatePayment(previous: CategoryPayment, with updated: CategoryPayment) {
        if previous.categoryId != updated.categoryId {
            deletePayment(id: previous.id, categoryId: previous.categoryId)
            addPayment(updated, to: updated.categoryId)
        } else {
            var paymentsCopy = paymentsByCategoryId
            guard var list = paymentsCopy[updated.categoryId],
                  let rowIndex = list.firstIndex(where: { $0.id == updated.id })
            else {
                return
            }

            let oldAmount = list[rowIndex].amount
            list[rowIndex] = updated
            paymentsCopy[updated.categoryId] = list
            paymentsByCategoryId = paymentsCopy

            let delta = updated.amount - oldAmount

            guard let categoryIndex = categories.firstIndex(where: {
                $0.id == updated.categoryId
            }) else {
                return
            }

            let category = categories[categoryIndex]
            categories[categoryIndex] = Category(
                id: category.id,
                emoji: category.emoji,
                name: category.name,
                type: category.type,
                spent: max(0, category.spent + delta),
                budget: category.budget,
                dailyLimit: category.dailyLimit,
                colorIndex: category.colorIndex,
                predefinedKey: category.predefinedKey
            )
        }
        persist()
    }

    // MARK: - Categorize unknown transaction (Filter)

    func categorizeUncategorized(_ transaction: ParsedTransaction, into category: Category) {
        guard let amount = transaction.amount else { return }

        let merchantName = transaction.merchantName ?? "Unknown Merchant"
        let keywordCategory = category.predefinedKey
            ?? transaction.categoryName
            ?? category.name

        MerchantKeywordStore.shared.addMerchant(merchantName, toCategory: keywordCategory)

        let payment = CategoryPayment(
            categoryId: category.id,
            merchantName: merchantName,
            date: transaction.date,
            amount: amount
        )

        addPayment(payment, to: category.id)

        BudgieNotificationService.shared.notifyExpenseTracked(
            merchant: merchantName,
            amount: amount,
            categoryName: category.name
        )

        uncategorizedTransactions.removeAll { $0.id == transaction.id }
        persist()
    }

    func removeUncategorized(_ transaction: ParsedTransaction) {
        uncategorizedTransactions.removeAll { $0.id == transaction.id }
        persist()
    }

    // MARK: - Find Category Using predefinedKey

    func category(
        matchingPredefinedKey key: String
    ) -> Category? {

        categories.first {

            guard let predefined = $0.predefinedKey else {
                return false
            }

            return predefined.caseInsensitiveCompare(key)
                == .orderedSame
        }
    }

    // MARK: - Add Payment Generic

    func addPayment(
        _ payment: CategoryPayment,
        merchantCategoryName: String? = nil,
        categoryId: UUID? = nil
    ) {

        let targetId: UUID?

        if let categoryId {

            targetId = categoryId

        } else if let merchantCategoryName,
                  let matchedCategory = category(
                    matchingPredefinedKey: merchantCategoryName
                  ) {

            targetId = matchedCategory.id

        } else {

            return
        }

        guard let targetId else { return }

        addPayment(payment, to: targetId)
    }

    // MARK: - Import SMS Transactions

    func importParsedTransactions(
        _ transactions: [ParsedTransaction]
    ) {
        let previousTotalSpent = totalSpentFromPayments

        for transaction in transactions {

            // Prevent duplicate imports
            guard !importedTransactionIds.contains(transaction.id)
            else {
                continue
            }

            importedTransactionIds.insert(transaction.id)

            let merchant = transaction.merchantName ?? "Unknown Merchant"

            // Amount required
            guard let amount = transaction.amount else {
                uncategorizedTransactions.append(transaction)
                BudgieNotificationService.shared.notifyNeedsFilter(
                    merchant: merchant,
                    amount: nil
                )
                continue
            }

            // Category match required
            guard let categoryName = transaction.categoryName,
                  let matchedCategory = category(
                    matchingPredefinedKey: categoryName
                  ) else {
                uncategorizedTransactions.append(transaction)
                BudgieNotificationService.shared.notifyNeedsFilter(
                    merchant: merchant,
                    amount: amount
                )
                continue
            }

            // Create payment
            let payment = CategoryPayment(
                categoryId: matchedCategory.id,
                merchantName: merchant,
                date: transaction.date,
                amount: amount
            )

            addPayment(payment, to: matchedCategory.id)

            BudgieNotificationService.shared.notifyExpenseTracked(
                merchant: merchant,
                amount: amount,
                categoryName: matchedCategory.name
            )
        }

        persist()

        BudgieNotificationService.shared.evaluateIncomeBudgetIfNeeded(
            totalIncome: budgetAlertTotalIncome,
            previousTotalSpent: previousTotalSpent,
            currentTotalSpent: totalSpentFromPayments
        )
    }

    // MARK: - Payments

    func payments(
        for categoryId: UUID
    ) -> [CategoryPayment] {

        paymentsByCategoryId[categoryId] ?? []
    }

    // MARK: - Find Category By Id

    func category(
        withId id: UUID
    ) -> Category? {

        categories.first {
            $0.id == id
        }
    }

    // MARK: - Styling

    func accentColor(
        for category: Category
    ) -> Color {

        CategoryStyling.color(forIndex: category.colorIndex)
    }

    func progressFillColor(
        for category: Category
    ) -> Color {

        category.progress >= 1
            ? .red
            : accentColor(for: category)
    }
}

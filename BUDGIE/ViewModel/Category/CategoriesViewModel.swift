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

    var isEmpty: Bool {
        categories.isEmpty
    }

    var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }
    }

    func add(_ category: Category) {
        categories.append(category)
    }

    func update(_ category: Category) {
        guard let index = categories.firstIndex(where: {
            $0.id == category.id
        }) else {
            return
        }

        categories[index] = category
    }

    func delete(id: UUID) {
        categories.removeAll { $0.id == id }
        var paymentsCopy = paymentsByCategoryId
        paymentsCopy.removeValue(forKey: id)
        paymentsByCategoryId = paymentsCopy
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
        categories[categoryIndex] = Category(
            id: category.id,
            emoji: category.emoji,
            name: category.name,
            type: category.type,
            spent: max(0, category.spent - removed.amount),
            budget: category.budget,
            dailyLimit: category.dailyLimit,
            colorIndex: category.colorIndex,
            predefinedKey: category.predefinedKey
        )
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

        for transaction in transactions {

            // Prevent duplicate imports
            guard !importedTransactionIds.contains(transaction.id)
            else {
                continue
            }

            importedTransactionIds.insert(transaction.id)

            // Amount required
            guard let amount = transaction.amount else {

                uncategorizedTransactions.append(transaction)

                continue
            }

            // Category match required
            guard let categoryName = transaction.categoryName,
                  let matchedCategory = category(
                    matchingPredefinedKey: categoryName
                  ) else {

                uncategorizedTransactions.append(transaction)

                continue
            }

            // Create payment
            let payment = CategoryPayment(
                categoryId: matchedCategory.id,
                merchantName:
                    transaction.merchantName
                    ?? "Unknown Merchant",
                date: transaction.date,
                amount: amount
            )

            // Add payment to category
            addPayment(
                payment,
                to: matchedCategory.id
            )
        }
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

        CategoryStyling.color(
            forIndex: category.colorIndex
        )
    }

    func progressFillColor(
        for category: Category
    ) -> Color {

        category.progress >= 1
            ? .red
            : accentColor(for: category)
    }
}

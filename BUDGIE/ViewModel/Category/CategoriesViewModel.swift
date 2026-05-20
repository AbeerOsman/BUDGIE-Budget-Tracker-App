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

        var list = paymentsByCategoryId[categoryId] ?? []

        list.insert(payment, at: 0)

        paymentsByCategoryId[categoryId] = list

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

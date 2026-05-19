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
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
    }

    func addPayment(_ payment: CategoryPayment, to categoryId: UUID) {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        let cat = categories[index]
        var list = paymentsByCategoryId[categoryId] ?? []
        list.insert(payment, at: 0)
        paymentsByCategoryId[categoryId] = list

        let updated = Category(
            id: cat.id,
            emoji: cat.emoji,
            name: cat.name,
            type: cat.type,
            spent: cat.spent + payment.amount,
            budget: cat.budget,
            dailyLimit: cat.dailyLimit,
            colorIndex: cat.colorIndex,
            predefinedKey: cat.predefinedKey
        )
        categories[index] = updated
    }

    /// Resolves a user category linked to a merchant_keywords.json key (e.g. from SMS detection).
    func category(matchingPredefinedKey key: String) -> Category? {
        categories.first {
            guard let predefined = $0.predefinedKey else { return false }
            return predefined.caseInsensitiveCompare(key) == .orderedSame
        }
    }

    /// Adds a payment when the merchant category name is known (SMS) or a specific category is chosen (manual).
    func addPayment(
        _ payment: CategoryPayment,
        merchantCategoryName: String? = nil,
        categoryId: UUID? = nil
    ) {
        let targetId: UUID?
        if let categoryId {
            targetId = categoryId
        } else if let name = merchantCategoryName, let matched = category(matchingPredefinedKey: name) {
            targetId = matched.id
        } else {
            return
        }
        guard let targetId else { return }
        addPayment(payment, to: targetId)
    }

    func payments(for categoryId: UUID) -> [CategoryPayment] {
        paymentsByCategoryId[categoryId] ?? []
    }

    func category(withId id: UUID) -> Category? {
        categories.first { $0.id == id }
    }

    func accentColor(for category: Category) -> Color {
        CategoryStyling.color(forIndex: category.colorIndex)
    }

    func progressFillColor(for category: Category) -> Color {
        category.progress >= 1 ? .red : accentColor(for: category)
    }
}

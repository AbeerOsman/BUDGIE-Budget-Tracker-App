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
            colorIndex: cat.colorIndex
        )
        categories[index] = updated
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

//
//  CategoryDetailViewModel.swift
//  BUDGIE
//

import Foundation
import Observation
import SwiftUI

@Observable
final class CategoryDetailViewModel {
    let categoryId: UUID
    private let categoriesViewModel: CategoriesViewModel

    init(categoryId: UUID, categoriesViewModel: CategoriesViewModel) {
        self.categoryId = categoryId
        self.categoriesViewModel = categoriesViewModel
    }

    var category: Category? {
        categoriesViewModel.category(withId: categoryId)
    }

    var accentColor: Color {
        guard let category else { return .skyBlue }
        return categoriesViewModel.accentColor(for: category)
    }

    var progressFillColor: Color {
        guard let category else { return accentColor }
        return categoriesViewModel.progressFillColor(for: category)
    }

    /// Payments for this category (newest first).
    var recentPayments: [CategoryPayment] {
        categoriesViewModel.payments(for: categoryId)
    }

    var navigationTitle: String {
        category?.name ?? String(localized: "Category")
    }

    func updateCategory(_ category: Category) {
        categoriesViewModel.update(category)
    }
}

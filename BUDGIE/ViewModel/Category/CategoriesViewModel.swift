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

    func accentColor(for category: Category) -> Color {
        CategoryStyling.color(forIndex: category.colorIndex)
    }

    func progressFillColor(for category: Category) -> Color {
        category.progress >= 1 ? .red : accentColor(for: category)
    }
}

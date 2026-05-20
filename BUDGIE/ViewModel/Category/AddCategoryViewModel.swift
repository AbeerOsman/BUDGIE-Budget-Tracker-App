//
//  AddCategoryViewModel.swift
//  BUDGIE
//

import Foundation
import Observation

@Observable
final class AddCategoryViewModel {
    enum Mode {
        case add(nextColorIndex: (CategoryType) -> Int)
        case edit(Category)
    }

    var title = ""
    var emoji = ""
    var categoryType: CategoryType = .spending
    var budget = ""
    var dailySpending = ""
    var selectedPredefinedKey: String?

    let mode: Mode
    let predefinedOptions: [String]
    private let categoriesViewModel: CategoriesViewModel
    private(set) var totalIncome: Double

    private var editingCategory: Category? {
        if case .edit(let category) = mode { return category }
        return nil
    }

    var isEditing: Bool {
        editingCategory != nil
    }

    var navigationTitle: String {
        isEditing ? "Edit Category" : "Add Category"
    }

    var usesCustomPredefinedLink: Bool {
        selectedPredefinedKey == nil
    }

    /// Even split of monthly budget across 30 days (updates as the user types budget).
    var recommendedDailyLimit: Int {
        let monthly = parsedAmount(from: budget)
        guard monthly > 0 else { return 0 }
        return Int((monthly / 30.0).rounded(.toNearestOrAwayFromZero))
    }

    init(
        mode: Mode,
        categoriesViewModel: CategoriesViewModel,
        totalIncome: Double,
        suggestedPredefinedKey: String? = nil
    ) {
        self.mode = mode
        self.categoriesViewModel = categoriesViewModel
        self.totalIncome = totalIncome
        self.predefinedOptions = PredefinedCategoryCatalog.categoryNames

        if let suggestedPredefinedKey,
           predefinedOptions.contains(where: {
               $0.caseInsensitiveCompare(suggestedPredefinedKey) == .orderedSame
           }) {
            setPredefinedPickerSelection(suggestedPredefinedKey)
        }

        if case .edit(let category) = mode {
            title = category.name
            emoji = category.emoji
            categoryType = category.type
            budget = String(Int(category.budget))
            selectedPredefinedKey = category.predefinedKey
            if let dailyLimit = category.dailyLimit {
                dailySpending = String(Int(dailyLimit))
            }
        }
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var proposedBudget: Double {
        parsedAmount(from: budget)
    }

    var budgetExceedsIncome: Bool {
        categoriesViewModel.wouldExceedIncome(
            proposedBudget: proposedBudget,
            totalIncome: totalIncome,
            excludingCategoryId: editingCategory?.id
        )
    }

    var budgetValidationMessage: String? {
        guard !budget.isEmpty, proposedBudget > 0 else { return nil }

        if totalIncome <= 0 {
            return "Add an income before allocating category budgets."
        }

        if budgetExceedsIncome {
            let remaining = Int(
                categoriesViewModel.remainingBudgetCapacity(
                    totalIncome: totalIncome,
                    excludingCategoryId: editingCategory?.id
                )
            )
            return "Category budgets can’t exceed your income ($\(Int(totalIncome))). You have $\(remaining) left to allocate."
        }

        return nil
    }

    var canSave: Bool {
        guard meetsFormRequirements, !budgetExceedsIncome else { return false }
        return true
    }

    func updateTotalIncome(_ amount: Double) {
        totalIncome = amount
    }

    private var meetsFormRequirements: Bool {
        let base = !trimmedTitle.isEmpty && !emoji.isEmpty && !budget.isEmpty
        if categoryType == .spending {
            return base && !dailySpending.isEmpty
        }
        return base
    }

    /// Uses non-optional picker value: empty string = Custom. Syncs title + emoji whenever a predefined key is chosen.
    func setPredefinedPickerSelection(_ raw: String) {
        if raw.isEmpty {
            selectedPredefinedKey = nil
            return
        }
        selectedPredefinedKey = raw
        title = raw
        emoji = PredefinedCategoryCatalog.defaultEmoji(for: raw)
    }

    func buildCategory() -> Category? {
        guard canSave else { return nil }

        let dailyLimit: Double? = categoryType == .spending
            ? parsedAmount(from: dailySpending)
            : nil

        let colorIndex: Int
        let spent: Double
        let id: UUID

        if let existing = editingCategory {
            id = existing.id
            spent = existing.spent
            colorIndex = existing.colorIndex
        } else if case .add(let nextColorIndex) = mode {
            id = UUID()
            spent = 0
            colorIndex = nextColorIndex(categoryType)
        } else {
            return nil
        }

        return Category(
            id: id,
            emoji: emoji.isEmpty ? "📁" : emoji,
            name: trimmedTitle,
            type: categoryType,
            spent: spent,
            budget: parsedAmount(from: budget),
            dailyLimit: dailyLimit,
            colorIndex: colorIndex,
            predefinedKey: selectedPredefinedKey
        )
    }

    func sanitizeTitle(_ input: String) -> String {
        let allowedPunctuation: Set<Character> = ["-", "'", "&"]
        return input.filter { character in
            character.isLetter
                || character.isWhitespace
                || allowedPunctuation.contains(character)
        }
    }

    func sanitizeDigits(_ input: String) -> String {
        input.filter(\.isNumber)
    }

    func sanitizeEmoji(_ input: String) -> String {
        for character in input.reversed() {
            if character.isEmojiCharacter {
                return String(character)
            }
        }
        return ""
    }

    private func parsedAmount(from text: String) -> Double {
        Double(Int(text.filter(\.isNumber)) ?? 0)
    }
}

private extension Character {
    var isEmojiCharacter: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }
}

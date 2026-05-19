//
//  AddCategoryViewModel.swift
//  BUDGIE
//

import Foundation
import Observation

@Observable
final class AddCategoryViewModel {
    enum Mode {
        case add(categoryIndex: Int)
        case edit(Category)
    }

    var title = ""
    var emoji = ""
    var categoryType: CategoryType = .spending
    var budget = ""
    var dailySpending = ""
    var selectedPredefinedKey: String?

    let mode: Mode
    let recommendedDailyLimit: Int
    let predefinedOptions: [String]

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

    init(mode: Mode, recommendedDailyLimit: Int = 50) {
        self.mode = mode
        self.recommendedDailyLimit = recommendedDailyLimit
        self.predefinedOptions = PredefinedCategoryCatalog.categoryNames

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

    var canSave: Bool {
        let base = !trimmedTitle.isEmpty && !emoji.isEmpty && !budget.isEmpty
        if categoryType == .spending {
            return base && !dailySpending.isEmpty
        }
        return base
    }

    func applyPredefinedSelection(_ key: String?) {
        selectedPredefinedKey = key
        guard let key else { return }

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            title = key
        }
        if emoji.isEmpty {
            emoji = PredefinedCategoryCatalog.defaultEmoji(for: key)
        }
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
        } else if case .add(let index) = mode {
            id = UUID()
            spent = 0
            colorIndex = CategoryStyling.colorIndex(for: index)
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

//
//  AddCategoryViewModel.swift
//  BUDGIE
//

import Foundation
import Observation

@Observable
final class AddCategoryViewModel {
    var title = ""
    var emoji = ""
    var categoryType: CategoryType = .spending
    var budget = ""
    var dailySpending = ""

    let categoryIndex: Int
    let recommendedDailyLimit: Int

    init(categoryIndex: Int, recommendedDailyLimit: Int = 50) {
        self.categoryIndex = categoryIndex
        self.recommendedDailyLimit = recommendedDailyLimit
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

    func buildCategory() -> Category? {
        guard canSave else { return nil }

        let dailyLimit: Double? = categoryType == .spending
            ? parsedAmount(from: dailySpending)
            : nil

        return Category(
            emoji: emoji.isEmpty ? "📁" : emoji,
            name: trimmedTitle,
            type: categoryType,
            spent: 0,
            budget: parsedAmount(from: budget),
            dailyLimit: dailyLimit,
            colorIndex: CategoryStyling.colorIndex(for: categoryIndex)
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

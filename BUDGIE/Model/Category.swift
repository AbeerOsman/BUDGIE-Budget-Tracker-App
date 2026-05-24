//
//  Category.swift
//  BUDGIE
//

import Foundation

struct Category: Identifiable, Equatable, Codable {
    let id: UUID
    let emoji: String
    let name: String
    let type: CategoryType
    let spent: Double
    let budget: Double
    let dailyLimit: Double?
    let colorIndex: Int
    /// Key from `merchant_keywords.json` (e.g. "Food") for transaction / merchant matching.
    let predefinedKey: String?

    init(
        id: UUID = UUID(),
        emoji: String,
        name: String,
        type: CategoryType,
        spent: Double,
        budget: Double,
        dailyLimit: Double? = nil,
        colorIndex: Int,
        predefinedKey: String? = nil
    ) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.type = type
        self.spent = spent
        self.budget = budget
        self.dailyLimit = dailyLimit
        self.colorIndex = colorIndex
        self.predefinedKey = predefinedKey
    }

    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1)
    }

    var remainingAmount: Double {
        max(budget - spent, 0)
    }

    var spentAmount: Int { Int(spent) }
    var budgetAmount: Int { Int(budget) }
    var remainingAmountInt: Int { Int(remainingAmount) }

    var progressPercentageText: String {
        BudgieNumericInput.formatPercent(progress)
    }

}

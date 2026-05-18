//
//  Category.swift
//  BUDGIE
//

import Foundation

struct Category: Identifiable, Equatable {
    let id: UUID
    let emoji: String
    let name: String
    let type: CategoryType
    let spent: Double
    let budget: Double
    let dailyLimit: Double?
    let colorIndex: Int

    init(
        id: UUID = UUID(),
        emoji: String,
        name: String,
        type: CategoryType,
        spent: Double,
        budget: Double,
        dailyLimit: Double? = nil,
        colorIndex: Int
    ) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.type = type
        self.spent = spent
        self.budget = budget
        self.dailyLimit = dailyLimit
        self.colorIndex = colorIndex
    }

    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1)
    }

    var budgetSummary: String {
        "$\(Int(spent)) / $\(Int(budget))"
    }

    var progressPercentageText: String {
        let value = progress * 100
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "%\(Int(value))"
        }
        return String(format: "%.1f%%", value)
    }
}

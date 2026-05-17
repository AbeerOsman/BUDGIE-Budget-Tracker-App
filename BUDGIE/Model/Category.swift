//
//  Category.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

import Foundation
import SwiftUI

struct Category: Identifiable {
    let id: UUID
    
    var name: String
    var icon: String
    
    var type: CategoryType
    
    var monthlyBudget: Double
    
    // فقط للـ spending
    var dailyLimit: Double?
    
    var spentAmount: Double
}

// MARK: - Display model (UI only)

struct CategoryCardItem: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    let type: CategoryType
    let spent: Double
    let budget: Double
    let color: Color
    
    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1)
    }
}

// MARK: - Preview Data

extension CategoryCardItem {

    /// Default icon colors in order: darkNavy → Sky Blue → Lime → Mint blue → Steel Blue
    private static let palette: [Color] = [
        .darkNavy,
        .skyBlue,
        .lime,
        .mintBlue,
        .steelBlue
    ]

    static func color(forIndex index: Int) -> Color {
        palette[index % palette.count]
    }

    static let previewItems: [CategoryCardItem] = [

        CategoryCardItem(
            emoji: "🍕",
            name: "Food & Dining",
            type: .spending,
            spent: 97,
            budget: 200,
            color: CategoryCardItem.color(forIndex: 0)
        ),

        CategoryCardItem(
            emoji: "🕹️",
            name: "Entertainment",
            type: .spending,
            spent: 38,
            budget: 150,
            color: CategoryCardItem.color(forIndex: 1)
        ),

        CategoryCardItem(
            emoji: "🚕",
            name: "Transport",
            type: .spending,
            spent: 75,
            budget: 150,
            color: CategoryCardItem.color(forIndex: 2)
        ),

        CategoryCardItem(
            emoji: "🛍️",
            name: "Shopping",
            type: .spending,
            spent: 135,
            budget: 150,
            color: CategoryCardItem.color(forIndex: 3)
        ),

        CategoryCardItem(
            emoji: "🏥",
            name: "Health",
            type: .spending,
            spent: 23,
            budget: 150,
            color: CategoryCardItem.color(forIndex: 4)
        ),

        CategoryCardItem(
            emoji: "💸",
            name: "Remaining",
            type: .spending,
            spent: 150,
            budget: 150,
            color: CategoryCardItem.color(forIndex: 5)
        )
    ]
}

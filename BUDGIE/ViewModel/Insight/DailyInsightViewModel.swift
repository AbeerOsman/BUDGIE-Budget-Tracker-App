//
//  DailyInsightViewModel.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

/**
 يعرض:
 chart حق 24 ساعة
 total spent today
 remaining today
 */
import Foundation
import SwiftUI
import Combine

final class DailyInsightViewModel: ObservableObject {

    // MARK: - Daily Spending

    @Published var totalSpentToday: Double = 33.04

    @Published var dailyBudget: Double = 77

    // MARK: - Remaining

    var remainingToday: Double {
        dailyBudget - totalSpentToday
    }

    // MARK: - Progress

    var progress: CGFloat {

        guard dailyBudget > 0 else {
            return 0
        }

        return CGFloat(totalSpentToday / dailyBudget)
    }
}

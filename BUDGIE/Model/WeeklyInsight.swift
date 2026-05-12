//
//  WeeklyInsight.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

import Foundation
struct WeeklyInsight {
    let id: UUID
    
    let weekStartDate: Date
    
    let totalSpent: Double
    
    let highestSpendingDay: String
    
    let dailySummaries: [DailySummary]
}

//
//  DailyInsight.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

import Foundation
struct DailyInsight {
    let id: UUID
    
    let date: Date
    
    let totalDailyLimit: Double
    
    let totalSpentToday: Double
    
    let remainingToday: Double
    
    let hourlyTransactions: [HourlySpending]
}

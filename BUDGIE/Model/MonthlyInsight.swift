//
//  MonthlyInsight.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 25/11/1447 AH.
//

import Foundation
import SwiftData

@Model
class MonthlyInsight {
    
    var id: UUID
    
    var monthStartDate: Date
    
    var totalSpent: Double
    
    var highestSpendingWeek: String
    
    init(
        id: UUID = UUID(),
        monthStartDate: Date,
        totalSpent: Double,
        highestSpendingWeek: String
    ) {
        self.id = id
        self.monthStartDate = monthStartDate
        self.totalSpent = totalSpent
        self.highestSpendingWeek = highestSpendingWeek
    }
}

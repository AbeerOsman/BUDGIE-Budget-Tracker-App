//
//  Category.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

import Foundation
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

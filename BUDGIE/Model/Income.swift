//
//  Item.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 01/12/1447 AH.
//

import Foundation
//
//  Item.swift
//  BUDGIE
//

import Foundation
import SwiftData

@Model
final class Income {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date
    var type: String // "income" or "expense"
    var category: String?
    var notes: String?
    var timestamp: Date
    
    init(
        title: String,
        amount: Double,
        date: Date,
        type: String,
        category: String? = nil,
        notes: String? = nil,
        timestamp: Date = Date()
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
        self.notes = notes
        self.timestamp = timestamp
    }
}

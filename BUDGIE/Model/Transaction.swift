//
//  Transaction.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 27/11/1447 AH.
//

import Foundation
import SwiftData
@Model
class Transaction{
    var id: UUID
    var userId: UUID?
    var categoryId: UUID?
    var merchantName: String
    var amount: Double
    var categoryName: String
    var rawMessage: String
    var source: TransactionSource
    var date: Date
    var isReviewed: Bool
    
    init(
        id: UUID = UUID(),
        userId: UUID?,
        categoryId: UUID?,
        merchantName: String,
        amount: Double,
        categoryName: String,
        rawMessage: String,
        source: TransactionSource,
        date: Date = Date(),
        isReviewed: Bool
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.merchantName = merchantName
        self.amount = amount
        self.categoryName = categoryName
        self.rawMessage = rawMessage
        self.source = source
        self.date = date
        self.isReviewed = isReviewed
    }
}

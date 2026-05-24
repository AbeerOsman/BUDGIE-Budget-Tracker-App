////
////  CategoryPayment.swift
////  BUDGIE
////
//
//import Foundation
//
//struct CategoryPayment: Identifiable, Equatable {
//    let id: UUID
//    let merchantName: String
//    let date: Date
//    let amount: Double
//
//    init(
//        id: UUID = UUID(),
//        merchantName: String,
//        date: Date,
//        amount: Double
//    ) {
//        self.id = id
//        self.merchantName = merchantName
//        self.date = date
//        self.amount = amount
//    }
//
//    var formattedDate: String {
//        date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year())
//    }
//
//    var formattedAmount: String {
//        "-$\(Int(amount))"
//    }
//}


import Foundation

struct CategoryPayment: Identifiable, Equatable, Codable {
    let id: UUID
    let categoryId: UUID
    let merchantName: String
    let date: Date
    let amount: Double

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        merchantName: String,
        date: Date,
        amount: Double
    ) {
        self.id = id
        self.categoryId = categoryId
        self.merchantName = merchantName
        self.date = date
        self.amount = amount
    }

    var formattedDate: String {
        date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year())
    }

    var amountValue: Int { Int(amount) }
}

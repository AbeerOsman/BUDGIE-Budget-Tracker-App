//
//  Transaction.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

import Foundation
struct Transaction: Identifiable{
    
    let id: UUID
    
    // المستخدم
    var userId: UUID
    
    // الكاتيجوري المرتبطة
    var categoryId: UUID?
    
    // معلومات العملية
    var amount: Double
    var merchantName: String
    
    // تاريخ العملية
    var date: Date
    
    // الرسالة الأصلية من البنك
    var rawMessage: String?
    
    // طريقة الدفع
    var paymentMethod: PaymentMethod
    
    // مصدر العملية
    var source: TransactionSource
    
    // هل تم مراجعتها يدويًا؟
    var isReviewed: Bool

}

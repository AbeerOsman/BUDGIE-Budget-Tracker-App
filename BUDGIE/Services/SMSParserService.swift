//
//  TransactionParserService.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//
//يحلل النص ويحوله Transaction.

import Foundation

// موديل مؤقت يمثل العملية بعد تحليل رسالة البنك
struct ParsedTransaction: Identifiable, Codable {
    let id: UUID
    let merchantName: String?
    let amount: Double?
    let categoryName: String?
    let rawMessage: String
    let date: Date
    
    init(
        id: UUID = UUID(),
        merchantName: String?,
        amount: Double?,
        categoryName: String?,
        rawMessage: String,
        date: Date = Date()
    ) {
        self.id = id
        self.merchantName = merchantName
        self.amount = amount
        self.categoryName = categoryName
        self.rawMessage = rawMessage
        self.date = date
    }
}

final class SMSParserService {
    
    // يحلل نص الرسالة ويطلع المبلغ، اسم التاجر، والتصنيف
    func parse(_ message: String) -> ParsedTransaction {
        // يحتوي على المبلغ المستخرج من رسالة البنك
        let amount = extractAmount(from: message)
        
        let keywordService = MerchantKeywordService()
        // يبحث داخل merchant_keywords.json عن اسم التاجر والتصنيف
        let keywordResult = keywordService.detectMerchant(in: message)
        // اسم التاجر النهائي المستخدم داخل التطبيق
        let merchantName = keywordResult?.merchantName ?? extractMerchantName(from: message)
        // التصنيف النهائي للعملية مثل Food أو Transport
        let categoryName = keywordResult?.categoryName
        
        return ParsedTransaction(
            merchantName: merchantName,
            amount: amount,
            categoryName: categoryName,
            rawMessage: message
        )
    }
    
    // يستخرج المبلغ من الرسالة إذا كان بجانب SAR / SR / ريال
    private func extractAmount(from message: String) -> Double? {
        let pattern = #"(?i)(?:SAR|SR|ر\.س|ريال)\s*([0-9]+(?:\.[0-9]{1,2})?)|([0-9]+(?:\.[0-9]{1,2})?)\s*(?:SAR|SR|ر\.س|ريال)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: message,
                range: NSRange(message.startIndex..., in: message)
              ) else {
            return nil
        }
        
        for index in 1..<match.numberOfRanges {
            let range = match.range(at: index)
            
            if range.location != NSNotFound,
               let swiftRange = Range(range, in: message) {
                return Double(message[swiftRange])
            }
        }
        
        return nil
    }
    
    // يحاول استخراج اسم التاجر من صيغ الرسائل الشائعة مثل "من" أو "at"
    private func extractMerchantName(from message: String) -> String? {
        let patterns = [
            #"(?i)(?:at|لدى|من)\s+([A-Za-z0-9\s\-\_\.]+)"#,
            #"(?i)(?:merchant|التاجر)\s*[:\-]?\s*([A-Za-z0-9\s\-\_\.]+)"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(
                in: message,
                range: NSRange(message.startIndex..., in: message)
               ),
               let range = Range(match.range(at: 1), in: message) {
                
                let merchant = String(message[range])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                return merchant.isEmpty ? nil : merchant
            }
        }
        
        return nil
    }
}

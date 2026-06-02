//
//  SMSReaderService.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//

//مسؤول عن استقبال بيانات الـ Shortcut.
//import Foundation
//class ShortcutService {
//    
////    func receiveTransaction(from message: String)
//}



import Foundation

final class ShortcutService {
    
    private let storageKey = "parsedTransactions"
    
    @discardableResult
    func receiveTransaction(from message: String) -> ParsedTransaction {
        let parser = SMSParserService()
        let parsedTransaction = parser.parse(message)
        save(parsedTransaction)
        return parsedTransaction
    }
    
    func getSavedTransactions() -> [ParsedTransaction] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let transactions = try? JSONDecoder().decode([ParsedTransaction].self, from: data) else {
            return []
        }
        
        return transactions
    }
    
    func clearTransactions() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    private func save(_ transaction: ParsedTransaction) {
        var transactions = getSavedTransactions()
        transactions.insert(transaction, at: 0)
        
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

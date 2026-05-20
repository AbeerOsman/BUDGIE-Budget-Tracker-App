//
//  PredefinedCategoryCatalog.swift
//  BUDGIE
//

import Foundation

/// Category names from `merchant_keywords.json` — used for SMS/merchant matching and user category linking.
enum PredefinedCategoryCatalog {
    private static let fileName = "merchant_keywords"

    private static let defaultEmojis: [String: String] = [
        "Food": "🍕",
        "Transport": "🚕",
        "Shopping": "🛍️",
        "Entertainment": "🕹️",
        "Subscriptions": "📱",
        "Health": "🏥",
        "Rent": "🏠",
        "Internet": "📶",
        "Bills": "💡"
    ]

    static var categoryNames: [String] {
        loadKeywords().keys.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    static func defaultEmoji(for categoryName: String) -> String {
        defaultEmojis[categoryName] ?? "📁"
    }

    static func loadKeywords() -> [String: [String]] {
        MerchantKeywordStore.shared.loadKeywords()
    }

    static func loadBundleKeywords() -> [String: [String]] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            return [:]
        }
        return decoded
    }
}

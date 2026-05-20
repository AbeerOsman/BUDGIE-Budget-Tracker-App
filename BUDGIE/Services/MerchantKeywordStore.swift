//
//  MerchantKeywordStore.swift
//  BUDGIE
//

import Foundation

/// Merges bundle `merchant_keywords.json` with user-added merchants saved on device.
final class MerchantKeywordStore {
    static let shared = MerchantKeywordStore()

    private let userFileName = "merchant_keywords_user"
    private var cachedKeywords: [String: [String]]?

    private init() {}

    func loadKeywords() -> [String: [String]] {
        if let cachedKeywords {
            return cachedKeywords
        }

        var merged = PredefinedCategoryCatalog.loadBundleKeywords()

        if let userOverrides = loadUserKeywords() {
            for (category, merchants) in userOverrides {
                var list = merged[category] ?? []
                for merchant in merchants {
                    if !list.contains(where: { Self.normalize($0) == Self.normalize(merchant) }) {
                        list.append(merchant)
                    }
                }
                merged[category] = list
            }
        }

        cachedKeywords = merged
        return merged
    }

    func allCategoryNames() -> [String] {
        loadKeywords().keys.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    /// Adds a merchant keyword under the given category and persists to disk.
    @discardableResult
    func addMerchant(_ merchant: String, toCategory categoryName: String) -> Bool {
        let keyword = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty, !categoryName.isEmpty else { return false }

        var userKeywords = loadUserKeywords() ?? [:]
        var list = userKeywords[categoryName] ?? []

        guard !list.contains(where: { Self.normalize($0) == Self.normalize(keyword) }) else {
            invalidateCache()
            return true
        }

        list.append(keyword.lowercased())
        userKeywords[categoryName] = list

        guard saveUserKeywords(userKeywords) else { return false }

        invalidateCache()
        return true
    }

    static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "*", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func invalidateCache() {
        cachedKeywords = nil
    }

    private var userFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("\(userFileName).json")
    }

    private func loadUserKeywords() -> [String: [String]]? {
        guard FileManager.default.fileExists(atPath: userFileURL.path),
              let data = try? Data(contentsOf: userFileURL),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            return nil
        }
        return decoded
    }

    @discardableResult
    private func saveUserKeywords(_ keywords: [String: [String]]) -> Bool {
        do {
            let data = try JSONEncoder().encode(keywords)
            try data.write(to: userFileURL, options: [.atomic])
            return true
        } catch {
            print("❌ Failed to save merchant keywords:", error)
            return false
        }
    }
}

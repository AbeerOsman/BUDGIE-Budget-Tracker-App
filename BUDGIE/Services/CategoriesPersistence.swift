//
//  CategoriesPersistence.swift
//  BUDGIE
//

import Foundation

struct PersistedCategoriesState: Codable {
    var categories: [Category]
    var paymentsByCategoryId: [String: [CategoryPayment]]
    var uncategorizedTransactions: [ParsedTransaction]
    var importedTransactionIds: [UUID]
    var lastConfirmedCategoryResetPeriod: String?
    var lastDeclinedCategoryResetPeriod: String?
}

enum CategoriesPersistence {
    private static let storageKey = "budgie.categories.state"

    static func load() -> PersistedCategoriesState? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(PersistedCategoriesState.self, from: data)
        else {
            return nil
        }
        return state
    }

    static func save(from viewModel: CategoriesViewModel) {
        let payments = viewModel.paymentsByCategoryId.reduce(into: [String: [CategoryPayment]]()) { result, pair in
            result[pair.key.uuidString] = pair.value
        }

        let state = PersistedCategoriesState(
            categories: viewModel.categories,
            paymentsByCategoryId: payments,
            uncategorizedTransactions: viewModel.uncategorizedTransactions,
            importedTransactionIds: Array(viewModel.importedTransactionIds),
            lastConfirmedCategoryResetPeriod: viewModel.lastConfirmedCategoryResetPeriod,
            lastDeclinedCategoryResetPeriod: viewModel.lastDeclinedCategoryResetPeriod
        )

        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    static func apply(_ state: PersistedCategoriesState, to viewModel: CategoriesViewModel) {
        viewModel.categories = state.categories
        viewModel.paymentsByCategoryId = state.paymentsByCategoryId.reduce(into: [:]) { result, pair in
            guard let id = UUID(uuidString: pair.key) else { return }
            result[id] = pair.value
        }
        viewModel.uncategorizedTransactions = state.uncategorizedTransactions
        viewModel.importedTransactionIds = Set(state.importedTransactionIds)
        viewModel.lastConfirmedCategoryResetPeriod = state.lastConfirmedCategoryResetPeriod
        viewModel.lastDeclinedCategoryResetPeriod = state.lastDeclinedCategoryResetPeriod
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

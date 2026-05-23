//
//  AppDataDeletionService.swift
//  BUDGIE
//

import Foundation
import SwiftData

enum AppDataDeletionService {

    @MainActor
    static func deleteAllUserData(
        modelContext: ModelContext,
        categoriesViewModel: CategoriesViewModel,
        appLockManager: AppLockManager
    ) throws {
        try deleteAllIncome(modelContext: modelContext)

        ShortcutService().clearTransactions()
        MerchantKeywordStore.shared.clearUserOverrides()
        CategoriesPersistence.clear()
        BudgieNotificationService.shared.clearAllNotificationState()

        categoriesViewModel.wipeAllUserData()

        appLockManager.isEnabled = false
        appLockManager.isUnlocked = true

        UserDefaults.standard.set(false, forKey: AppSessionController.hasOnboardedKey)
    }

    @MainActor
    private static func deleteAllIncome(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<Income>()
        let records = try modelContext.fetch(descriptor)
        for record in records {
            modelContext.delete(record)
        }
        try modelContext.save()
    }
}

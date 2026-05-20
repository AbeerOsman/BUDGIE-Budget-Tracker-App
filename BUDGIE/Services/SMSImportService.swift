//
//  SMSImportService.swift
//  BUDGIE
//
//  Created by wasan jayid althagafi on 02/12/1447 AH.
//

import Foundation

final class SMSImportService {
    private let shortcutService = ShortcutService()

    func importSavedTransactions(into viewModel: CategoriesViewModel) {
        let transactions = shortcutService.getSavedTransactions()
        viewModel.importParsedTransactions(transactions)
    }
}

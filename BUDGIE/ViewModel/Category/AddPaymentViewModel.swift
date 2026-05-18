//
//  AddPaymentViewModel.swift
//  BUDGIE
//

import Foundation
import Observation

@Observable
final class AddPaymentViewModel {
    var title = ""
    var amount = ""
    var date: Date
    var selectedCategoryId: UUID

    private let categories: [Category]

    init(initialCategoryId: UUID, categories: [Category], defaultDate: Date = Date()) {
        self.selectedCategoryId = initialCategoryId
        self.categories = categories
        self.date = defaultDate
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedTitle.isEmpty && parsedAmount > 0
    }

    var categoryOptions: [Category] {
        categories
    }

    func buildPayment() -> (payment: CategoryPayment, categoryId: UUID)? {
        guard canSave else { return nil }
        let payment = CategoryPayment(
            merchantName: trimmedTitle,
            date: date,
            amount: parsedAmount
        )
        return (payment, selectedCategoryId)
    }

    func sanitizeTitle(_ input: String) -> String {
        let allowedPunctuation: Set<Character> = ["-", "'", "&", ".", ","]
        return input.filter { character in
            character.isLetter
                || character.isNumber
                || character.isWhitespace
                || allowedPunctuation.contains(character)
        }
    }

    func sanitizeAmount(_ input: String) -> String {
        input.filter(\.isNumber)
    }

    private var parsedAmount: Double {
        Double(Int(amount.filter(\.isNumber)) ?? 0)
    }
}

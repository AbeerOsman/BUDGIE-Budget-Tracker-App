//
//  BankSMSIntentService.swift
//  BUDGIE
//
//  Created by wasan jayid althagafi on 26/11/1447 AH.
//
//
//  BankSMSIntentService.swift
//  BUDGIE
//

import Foundation
import AppIntents

struct ProcessBankSMSIntent: AppIntent {

    static var title: LocalizedStringResource =
        "Process Bank SMS"

    static var description = IntentDescription(
        "Send bank SMS message to BUDGIE app"
    )

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Bank SMS Message")
    var messageText: String

    static var parameterSummary: some ParameterSummary {
        Summary("Process bank SMS: \(\.$messageText)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let shortcutService = ShortcutService()

        guard let parsed = shortcutService.receiveTransaction(
            from: messageText
        ) else {
            print("❌ SMS ignored - no notification sent")
            return .result()
        }

        BudgieNotificationService.shared
            .notifyIncomingSMSTransaction(
                merchant: parsed.merchantName,
                amount: parsed.amount,
                categoryName: parsed.categoryName
            )

        print("🔔 Transaction notification sent")

        return .result()
    }
}

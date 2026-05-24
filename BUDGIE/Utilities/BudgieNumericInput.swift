//
//  BudgieNumericInput.swift
//  BUDGIE
//

import Foundation
import UIKit

/// Normalizes Arabic/Persian digits to Western (0–9) for typing, parsing, and UI display.
enum BudgieNumericInput {
    enum FieldKind {
        case integer
        case decimal
    }

    /// Always use Western digits (0–9) in the UI, even when the app language is Arabic.
    nonisolated private static let westernLocale = Locale(identifier: "en_US_POSIX")

    /// Allows Arabic or Western digit entry (always stored/displayed as 0–9 in fields).
    nonisolated static func keyboardType(for kind: FieldKind) -> UIKeyboardType {
        switch kind {
        case .integer, .decimal:
            .decimalPad
        }
    }

    /// Western digits only — use for every numeric `TextField` while typing.
    nonisolated static func displayText(for raw: String, kind: FieldKind) -> String {
        switch kind {
        case .integer:
            sanitizeIntegerInput(raw)
        case .decimal:
            sanitizeDecimalInput(raw)
        }
    }

    nonisolated static func normalizedASCII(for raw: String, kind: FieldKind) -> String {
        displayText(for: raw, kind: kind)
    }

    /// Converts Arabic-Indic (٠–٩) and Persian (۰–۹) digits to Western (0–9).
    nonisolated static func normalizedDigits(_ input: String) -> String {
        String(input.map { Self.normalizeDigit($0) })
    }

    nonisolated static func sanitizeIntegerInput(_ input: String) -> String {
        normalizedDigits(input).filter { $0.isASCII && $0.isNumber }
    }

    nonisolated static func sanitizeDecimalInput(_ input: String) -> String {
        let normalized = normalizedDigits(input)
        var result = ""
        var hasSeparator = false

        for char in normalized {
            if char.isASCII && char.isNumber {
                result.append(char)
            } else if (char == "." || char == "," || char == "٫") && !hasSeparator {
                result.append(".")
                hasSeparator = true
            }
        }

        return result
    }

    nonisolated static func parseInteger(from input: String) -> Int? {
        let sanitized = sanitizeIntegerInput(input)
        guard !sanitized.isEmpty else { return nil }
        return Int(sanitized)
    }

    nonisolated static func parseDouble(from input: String) -> Double? {
        let sanitized = sanitizeDecimalInput(input)
        guard !sanitized.isEmpty else { return nil }
        return Double(sanitized)
    }

    /// Western digits for amount text fields (income, budget inputs).
    nonisolated static func formatAmountForField(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }

    nonisolated static func formatInteger(_ value: Int) -> String {
        String(format: "%d", locale: westernLocale, value)
    }

    nonisolated static func formatDecimal(
        _ value: Double,
        maximumFractionDigits: Int = 2,
        minimumFractionDigits: Int? = nil
    ) -> String {
        let formatter = NumberFormatter()
        formatter.locale = westernLocale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        if let minimumFractionDigits {
            formatter.minimumFractionDigits = minimumFractionDigits
        } else if value == floor(value) {
            formatter.minimumFractionDigits = 0
        } else {
            formatter.minimumFractionDigits = min(2, maximumFractionDigits)
        }
        return formatter.string(from: NSNumber(value: value))
            ?? formatAmountForField(value)
    }

    nonisolated static func formatAmountForDisplay(_ value: Double) -> String {
        formatAmountForField(value)
    }

    /// Numeric amount only (no currency symbol — use `CurrencyAmountView` in SwiftUI).
    nonisolated static func formatAmount(_ value: Int) -> String {
        formatInteger(value)
    }

    nonisolated static func formatAmount(_ value: Double) -> String {
        if value == floor(value) {
            return formatInteger(Int(value))
        }
        return formatDecimal(value, maximumFractionDigits: 2)
    }

    /// Backward-compatible alias; ignores any symbol and returns digits only.
    nonisolated static func formatCurrency(_ value: Int, symbol: String = "") -> String {
        formatAmount(value)
    }

    nonisolated static func formatCurrency(_ value: Double, symbol: String = "") -> String {
        formatAmount(value)
    }

    nonisolated static func formatPercent(_ fraction: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = westernLocale
        formatter.numberStyle = .percent
        if (fraction * 100).truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 1
        }
        return formatter.string(from: NSNumber(value: fraction))
            ?? "\(formatInteger(Int(fraction * 100)))%"
    }

    nonisolated private static func normalizeDigit(_ char: Character) -> Character {
        guard let scalar = char.unicodeScalars.first else { return char }

        switch scalar.value {
        case 0x0660...0x0669:
            return Character(UnicodeScalar(0x30 + scalar.value - 0x0660)!)
        case 0x06F0...0x06F9:
            return Character(UnicodeScalar(0x30 + scalar.value - 0x06F0)!)
        default:
            return char
        }
    }
}

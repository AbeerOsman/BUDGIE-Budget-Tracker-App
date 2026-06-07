//
//  CurrencyAmountView.swift
//  BUDGIE
//

import SwiftUI

/// Saudi Riyal symbol from assets (template: black in light mode, white in dark mode).
struct SARIcon: View {
    var size: CGFloat = 16
    var tint: Color?

    @Environment(\.colorScheme) private var colorScheme

    private var resolvedTint: Color {
        if let tint { return tint }
        return colorScheme == .dark ? .white : .black
    }

    var body: some View {
        Image("SAR")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(resolvedTint)
    }
}

/// Amount with SAR icon (Western digits + asset symbol).
struct CurrencyAmountView: View {
    let amount: Int
    var font: Font = .body
    var weight: Font.Weight? = nil
    var iconSize: CGFloat = 16
    var tint: Color? = nil
    var prefix: String?

    var body: some View {
        HStack(spacing: 4) {
            if let prefix {
                Text(prefix)
                    .font(font.weight(weight ?? .regular))
            }

            Text(BudgieNumericInput.formatAmount(amount))
                .font(font.weight(weight ?? .regular))

            SARIcon(size: iconSize, tint: tint)
        }
        .foregroundStyle(tint ?? Color.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

struct CurrencyAmountDoubleView: View {
    let amount: Double
    var font: Font = .body
    var weight: Font.Weight? = nil
    var iconSize: CGFloat = 16
    var tint: Color? = nil
    var prefix: String?

    var body: some View {
        HStack(spacing: 4) {
            if let prefix {
                Text(prefix)
                    .font(font.weight(weight ?? .regular))
            }

            Text(BudgieNumericInput.formatAmount(amount))
                .font(font.weight(weight ?? .regular))

            SARIcon(size: iconSize, tint: tint)
        }
        .foregroundStyle(tint ?? Color.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

/// e.g. `50 / 200` with SAR after each amount.
struct CurrencyRatioView: View {
    let leading: Int
    let trailing: Int
    var font: Font = .body
    var iconSize: CGFloat = 14
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 4) {
            CurrencyAmountView(
                amount: leading,
                font: font,
                iconSize: iconSize,
                tint: tint
            )

            Text("/")
                .font(font)

            CurrencyAmountView(
                amount: trailing,
                font: font,
                iconSize: iconSize,
                tint: tint
            )
        }
        .foregroundStyle(tint ?? Color.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

/// Localized label + amount + SAR (e.g. "Spent 50 ﷼").
struct LabeledCurrencyView: View {
    let label: LocalizedStringKey
    let amount: Int
    var font: Font = .subheadline
    var iconSize: CGFloat = 14
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(font)

            CurrencyAmountView(
                amount: amount,
                font: font,
                iconSize: iconSize,
                tint: tint
            )
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

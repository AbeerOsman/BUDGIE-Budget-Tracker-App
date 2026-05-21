//
//  FilterToolbarButton.swift
//  BUDGIE
//

import SwiftUI

struct FilterToolbarButton: View {
    @Environment(\.colorScheme) private var colorScheme

    let showsBadge: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.body.weight(.medium))
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            if showsBadge {
                Circle()
                    .fill(Color.red)
                    .frame(width: 9, height: 9)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )
                    .offset(x: 5, y: -5)
            }
        }
        .accessibilityLabel("Filter unknown transactions")
        .accessibilityHint(
            showsBadge
                ? "Uncategorized transactions need your attention"
                : "Review uncategorized transactions"
        )
    }
}

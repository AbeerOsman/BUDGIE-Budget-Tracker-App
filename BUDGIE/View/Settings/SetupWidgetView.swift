//
//  SetupWidgetView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 19/12/1447 AH.
//
import SwiftUI

struct SetupWidgetView: View {
    var body: some View {
        ScrollView {
            WidgetSetupInstructionsContent()
                .padding(.vertical, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Setup Widget")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WidgetSetupInstructionsContent: View {
    var showsHowToTitle: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    private let steps: [LocalizedStringKey] = [
        "Long press on the Lock Screen",
        "Tap Customize → Lock Screen",
        "Tap the widget area below the clock",
        "Search for BUDGIE and add the widget"
    ]

    var body: some View {
        VStack(spacing: 28) {
            if showsHowToTitle {
                Text("How to add the widget?")
                    .font(BudgieFont.title2)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lock.square")
                        .foregroundStyle(.secondary)

                    Text("Add widget to Lock Screen")
                        .font(BudgieFont.headline)
                        .foregroundStyle(.primary)

                    Spacer()
                }

                VStack(spacing: 14) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        StepRow(number: index + 1, text: step)
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(cardBackground)
            )
            .padding(.horizontal, 20)

            Spacer(minLength: 20)
        }
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color.gray.opacity(0.12)
            : Color.gray.opacity(0.08)
    }
}

// MARK: - Subview for Step Row

struct StepRow: View {
    let number: Int
    let text: LocalizedStringKey

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(stepCircleFill)
                    .frame(width: 30, height: 30)

                Text("\(number)")
                    .font(BudgieFont.subheadline.weight(.bold))
                    .foregroundStyle(stepNumberColor)
            }

            Text(text)
                .font(BudgieFont.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private var stepCircleFill: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.15)
            : Color.black.opacity(0.12)
    }

    private var stepNumberColor: Color {
        colorScheme == .dark ? .white : .primary
    }
}

#Preview("Light") {
    NavigationStack {
        SetupWidgetView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        SetupWidgetView()
    }
    .preferredColorScheme(.dark)
}

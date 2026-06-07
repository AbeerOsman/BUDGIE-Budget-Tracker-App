//
//  IncomeOnboardingScreens.swift
//  BUDGIE
//
//  Created by Assistant on 20/05/2026.
//

import SwiftUI

// MARK: - Income Form

struct IncomeFormView: View {
    var onSave: (String, Double, Int, Int) -> Void
    var onSkip: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTitleFocused: Bool

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var fromDay: Int = min(31, max(1, Calendar.current.component(.day, from: Date())))
    @State private var toDay: Int = min(31, max(1, Calendar.current.component(.day, from: Date())))

    private var canSave: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && (BudgieNumericInput.parseDouble(from: amount) ?? 0) > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Add Your Income")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 4)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 22) {
                        // Title
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Income Source")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("e.g., Salary, Freelance, Business", text: $title)
                                .focused($isTitleFocused)
                                .foregroundColor(.primary)

                            Divider()
                                .background(Color.gray.opacity(0.5))
                        }

                        // Amount
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundColor(.gray)

                            WesternDigitField(
                                placeholder: "0.00",
                                text: $amount,
                                kind: .decimal
                            )
                            .foregroundColor(.primary)

                            Divider()
                                .background(Color.gray.opacity(0.5))
                        }

                        // Income Period (no calendar).
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Income Period")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            IncomePayDayRangePicker(
                                fromDay: $fromDay,
                                toDay: $toDay,
                                fromLabel: "From Day",
                                toLabel: "To Day"
                            )
                            .colorScheme(colorScheme == .dark ? .dark : .light)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(25)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.gray.opacity(0.08))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                Text("You can add more income sources later from Settings > Income Details.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                VStack(spacing: 12) {
                    Button {
                        isTitleFocused = false
                        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let value = BudgieNumericInput.parseDouble(from: amount) ?? 0
                        onSave(trimmed, value, fromDay, toDay)
                    } label: {
                        Text("Save Income")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(canSave ? Color.skyBlue : Color.skyBlue.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .disabled(!canSave)

                    Button {
                        isTitleFocused = false
                        onSkip()
                    } label: {
                        Text("I'll do it later")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

#Preview {
    IncomeFormView(onSave: { _, _, _, _ in }, onSkip: {})
        .padding()
}

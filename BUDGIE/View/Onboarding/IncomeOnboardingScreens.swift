//
//  IncomeOnboardingScreens.swift
//  BUDGIE
//
//  Created by Assistant on 20/05/2026.
//

import SwiftUI

// MARK: - SCREEN 1: Intro

struct IncomeIntroView: View {
    var onSetup: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SetupStepProgress(currentStep: 1)
            Spacer()

            VStack(spacing: 22) {
                Text("Add Your Income")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Start by adding your main income so Budgie can calculate your spending and remaining budget.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onSetup) {
                    Text("Set Up Income")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }

                Button(action: onSkip) {
                    Text("Skip")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - SCREEN 2: Form

struct IncomeFormView: View {
    var onSave: (String, Double, Int, Int) -> Void

    @Environment(\.colorScheme) private var colorScheme

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
            SetupStepProgress(currentStep: 1)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 22) {
                        // Title
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Income Source")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("e.g., Salary, Freelance, Business", text: $title)
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

                Button {
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
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
            }
        }
    }
}

// MARK: - SCREEN 3: Ready

struct IncomeReadyView: View {
    var onContinue: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SetupStepProgress(currentStep: 1)
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.skyBlue)

                Text("Income Saved")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Great! Now let’s set up automation so your expenses are tracked automatically.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }

                Button(action: onSkip) {
                    Text("I’ll do it later")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    VStack {
        IncomeIntroView(onSetup: {}, onSkip: {})
        IncomeFormView { _, _, _, _ in }
        IncomeReadyView(onContinue: {}, onSkip: {})
    }
    .padding()
}

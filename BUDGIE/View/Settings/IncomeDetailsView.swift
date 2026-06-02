//
//  IncomeDetailsView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman on 30/11/1447 AH.
//

import SwiftUI
import SwiftData

struct IncomeDetailsView: View {
    private enum AmountField: Hashable {
        case main
        case adjustment
    }

    @State private var title = ""
    @State private var amount = ""
    @State private var fromDay: Int = min(31, max(1, Calendar.current.component(.day, from: Date())))
    @State private var toDay: Int = min(31, max(1, Calendar.current.component(.day, from: Date())))
    @State private var editingIncome: Income?
    @State private var didLoadSavedIncome = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Income> { $0.type == "income" },
        sort: \Income.timestamp
    )
    private var savedIncomes: [Income]

    var onSave: () -> Void

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        (BudgieNumericInput.parseDouble(from: amount) ?? 0) > 0
    }

    @FocusState private var amountFieldFocus: AmountField?
    @State private var amountAdjustment = ""

    private var parsedAmount: Double? {
        BudgieNumericInput.parseDouble(from: amount)
    }

    private var showAmountMathTool: Bool {
        let amountSectionFocused =
            amountFieldFocus == .main || amountFieldFocus == .adjustment
        return amountSectionFocused && (parsedAmount ?? 0) > 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {

                    VStack(spacing: 22) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Income Source")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("e.g., Salary, Freelance, Business", text: $title)
                                .foregroundColor(.primary)

                            Divider()
                                .background(Color.gray.opacity(0.5))
                        }

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
                            .focused($amountFieldFocus, equals: .main)

                            Divider()
                                .background(Color.gray.opacity(0.5))

                            if showAmountMathTool {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Add or subtract")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    WesternDigitField(
                                        placeholder: "0.00",
                                        text: $amountAdjustment,
                                        kind: .decimal
                                    )
                                    .foregroundColor(.primary)
                                    .focused($amountFieldFocus, equals: .adjustment)

                                    HStack(spacing: 12) {
                                        Button {
                                            applyAmountMath(isAdd: true)
                                        } label: {
                                            Label("Add", systemImage: "plus")
                                                .font(.subheadline.weight(.semibold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.skyBlue.opacity(0.2))
                                                .foregroundColor(.skyBlue)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            applyAmountMath(isAdd: false)
                                        } label: {
                                            Label("Subtract", systemImage: "minus")
                                                .font(.subheadline.weight(.semibold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.gray.opacity(0.15))
                                                .foregroundColor(.primary)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }

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

                Text("You can always add other income sources like freelance work, gifts, rewards, or any extra earnings.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                Button(action: saveIncome) {
                    Text("Save Income")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(isValid ? Color.skyBlue : Color.skyBlue.opacity(0.5))
                        .clipShape(Capsule())
                }
                .disabled(!isValid)
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
            }
            .padding(.top, 5)
            
        }
        .navigationTitle("Income Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear(perform: loadSavedIncomeIfNeeded)
        .onChange(of: savedIncomes.count) { _, _ in
            if editingIncome == nil {
                loadSavedIncomeIfNeeded()
            }
        }
        .onChange(of: amountFieldFocus) { _, newFocus in
            if newFocus == nil {
                amountAdjustment = ""
            }
        }
    }

    private func applyAmountMath(isAdd: Bool) {
        let base = parsedAmount ?? 0
        let trimmedAdj = amountAdjustment.trimmingCharacters(in: .whitespacesAndNewlines)
        let delta = BudgieNumericInput.parseDouble(from: trimmedAdj) ?? 0
        guard base > 0, delta > 0 else { return }

        let newValue = isAdd ? base + delta : max(0, base - delta)
        amount = formatAmount(newValue)
        amountAdjustment = ""
    }

    private func loadSavedIncomeIfNeeded() {
        guard !didLoadSavedIncome, let primary = savedIncomes.first else { return }

        editingIncome = primary
        title = primary.title
        amount = formatAmount(primary.amount)
        fromDay = primary.normalizedSalaryPeriodFromDay
        toDay = primary.normalizedSalaryPeriodToDay
        didLoadSavedIncome = true
    }

    private func saveIncome() {
        guard let incomeAmount = BudgieNumericInput.parseDouble(from: amount) else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 31
        let effectiveToDay = min(max(toDay, 1), daysInMonth)
        
        var dateComponents = calendar.dateComponents([.year, .month], from: Date())
        dateComponents.day = effectiveToDay
        let paydayDate = calendar.date(from: dateComponents) ?? Date()

        if let existing = editingIncome {
            existing.title = trimmedTitle
            existing.amount = incomeAmount
            existing.salaryPeriodFromDay = min(max(fromDay, 1), 31)
            existing.salaryPeriodToDay = min(max(toDay, 1), 31)
            existing.date = paydayDate
            existing.timestamp = Date()
        } else {
            let newIncome = Income(
                title: trimmedTitle,
                amount: incomeAmount,
                date: Date(),
                type: "income",
                salaryPeriodFromDay: fromDay,
                salaryPeriodToDay: toDay
            )
            modelContext.insert(newIncome)
            editingIncome = newIncome
            didLoadSavedIncome = true
        }

        do {
            try modelContext.save()
            title = trimmedTitle
            amount = formatAmount(incomeAmount)
            BudgieNotificationService.shared.scheduleMonthlyResetReminder(resetDay: toDay)
            onSave()
            dismiss()
        } catch {
            print("Error saving income: \(error)")
        }
    }

    private func formatAmount(_ value: Double) -> String {
        BudgieNumericInput.formatAmountForDisplay(value)
    }
}

#Preview {
    NavigationStack {
        IncomeDetailsView(onSave: {})
    }
    .modelContainer(for: Income.self, inMemory: true)
}

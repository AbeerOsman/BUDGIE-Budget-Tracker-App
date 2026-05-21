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
    @State private var date = Date()
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
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }

    @FocusState private var amountFieldFocus: AmountField?
    @State private var amountAdjustment = ""

    private var parsedAmount: Double? {
        let trimmed = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed)
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

                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary)
                                .focused($amountFieldFocus, equals: .main)

                            Divider()
                                .background(Color.gray.opacity(0.5))

                            if showAmountMathTool {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Add or subtract")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    TextField("0.00", text: $amountAdjustment)
                                        .keyboardType(.decimalPad)
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

                        DatePicker(
                            "Date of Income",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .colorScheme(colorScheme == .dark ? .dark : .light)
                        .foregroundColor(.primary)
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
        let delta = Double(trimmedAdj) ?? 0
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
        date = primary.date
        didLoadSavedIncome = true
    }

    private func saveIncome() {
        guard let incomeAmount = Double(amount) else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)

        if let existing = editingIncome {
            existing.title = trimmedTitle
            existing.amount = incomeAmount
            existing.date = date
            existing.timestamp = Date()
        } else {
            let newIncome = Income(
                title: trimmedTitle,
                amount: incomeAmount,
                date: date,
                type: "income"
            )
            modelContext.insert(newIncome)
            editingIncome = newIncome
            didLoadSavedIncome = true
        }

        do {
            try modelContext.save()
            title = trimmedTitle
            amount = formatAmount(incomeAmount)
            onSave()
            dismiss()
        } catch {
            print("Error saving income: \(error)")
        }
    }

    private func formatAmount(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}

#Preview {
    NavigationStack {
        IncomeDetailsView(onSave: {})
    }
    .modelContainer(for: Income.self, inMemory: true)
}

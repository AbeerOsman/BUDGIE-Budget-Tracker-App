//
//  IncomeDetailsView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman on 30/11/1447 AH.
//

import SwiftUI
import SwiftData

struct IncomeDetailsView: View {
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Income]
    
    var onSave: () -> Void

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    var incomes: [Income] {
        items.filter { $0.type == "income" }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Show existing incomes
                if !incomes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Income Sources")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        ForEach(incomes) { income in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(income.title)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(income.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("$\(Int(income.amount))")
                                    .font(.headline)
                                    .foregroundColor(.skyBlue)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.08))
                            )
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                    }
                }
                
                // Add new income form
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Income Source")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
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
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
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
                
                Spacer()
                
                Button(action: {
                    if let incomeAmount = Double(amount) {
                        let newIncome = Income(
                            title: title,
                            amount: incomeAmount,
                            date: date,
                            type: "income"
                        )
                        modelContext.insert(newIncome)
                        
                        do {
                            try modelContext.save()
                            // Reset form
                            title = ""
                            amount = ""
                            date = Date()
                            onSave()
                        } catch {
                            print("Error saving income: \(error)")
                        }
                    }
                }) {
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
                .padding(.vertical, 20)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Income Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    IncomeDetailsView(onSave: {})
}

//
//  FilterView.swift
//  BUDGIE
//

import SwiftUI

// MARK: - Row View

struct FilterRowView: View {
    @Environment(\.colorScheme) var colorScheme

    let item: FilterItem

    static var whiteToGrayGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.gray]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {

        HStack(spacing: 16) {

            RoundedRectangle(cornerRadius: 14)
                .fill(FilterRowView.whiteToGrayGradient)
                .frame(width: 57, height: 57)
                .overlay(
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 26))
                        .foregroundColor(.black)
                )

            VStack(alignment: .leading, spacing: 4) {

                Text(item.merchantName)
                    .font(.system(size: 17, weight: .regular))

                Text(item.date)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack {
                Text("-\(Int(item.amount)) ")
                    .font(.system(size: 22, weight: .bold))

                Image("SAR")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Main View

struct FilterView: View {

    @Environment(CategoriesViewModel.self)
    private var categoriesViewModel

    // Categories
    let categories = [
        "Food",
        "Transport",
        "Entertainment",
        "Shopping",
        "Bills"
    ]

    // Transactions
    @State var items: [FilterItem]

    // Selected Item
    @State private var selectedItem: FilterItem?

    // Category Sheet
    @State private var showCategorySheet = false

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Filter")
                .font(.system(size: 17, weight: .semibold))
                .padding(.leading, 15)

            VStack(alignment: .leading, spacing: 4) {

                Text("Uncategorized Payments")
                    .font(.system(size: 25, weight: .bold))

                Text("Tap a transaction to assign a category")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 15)

            List {

                ForEach(items) { item in

                    FilterRowView(item: item)
                        .listRowSeparator(.hidden)
                        .contentShape(Rectangle())

                        .onTapGesture {
                            selectedItem = item
                            showCategorySheet = true
                        }

                        .swipeActions(edge: .trailing) {

                            Button(role: .destructive) {

                                deleteItem(item)

                            } label: {

                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemBackground))
        }

        .sheet(isPresented: $showCategorySheet) {

            VStack(alignment: .center, spacing: 10) {

                Text("Select Category")
                    .font(.title.bold())

                ForEach(categories, id: \.self) { category in

                    Button {

                        assignCategory(category)

                    } label: {

                        HStack {

                            Text(category)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                    }
                }

                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Functions

extension FilterView {

    func deleteItem(_ item: FilterItem) {

        items.removeAll {
            $0.id == item.id
        }

        categoriesViewModel
            .uncategorizedTransactions
            .removeAll {
                $0.id == item.parsedTransaction.id
            }
    }

    func assignCategory(_ category: String) {

        guard let selectedItem else {
            return
        }

        guard let matchedCategory =
                categoriesViewModel.category(
                    matchingPredefinedKey: category
                )
        else {

            print("❌ No user category found for:", category)

            return
        }

        let transaction = selectedItem.parsedTransaction

        guard let amount = transaction.amount else {
            return
        }

        let payment = CategoryPayment(
            categoryId: matchedCategory.id,
            merchantName: transaction.merchantName ?? "Unknown Merchant",
            date: transaction.date,
            amount: amount
        )

        categoriesViewModel.addPayment(
            payment,
            to: matchedCategory.id
        )

        categoriesViewModel
            .uncategorizedTransactions
            .removeAll {
                $0.id == transaction.id
            }

        items.removeAll {
            $0.id == selectedItem.id
        }

        print("✅ Assigned to:", matchedCategory.name)

        showCategorySheet = false
    }
}

#Preview {
    FilterView(items: [])
        .environment(CategoriesViewModel())
}

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
    @Environment(CategoriesViewModel.self) private var categoriesViewModel

    @State private var selectedItem: FilterItem?
    @State private var showCategorySheet = false
    @State private var showAddCategorySheet = false

    private var filterItems: [FilterItem] {
        categoriesViewModel.uncategorizedTransactions.map { transaction in
            FilterItem(
                id: transaction.id,
                merchantName: transaction.merchantName ?? "Unknown Merchant",
                date: transaction.date.formatted(
                    date: .abbreviated,
                    time: .shortened
                ),
                amount: transaction.amount ?? 0,
                parsedTransaction: transaction
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Uncategorized Payments")
                    .font(.system(size: 25, weight: .bold))

                Text("Tap a transaction to assign a category")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 24)

            if filterItems.isEmpty {
                ContentUnavailableView(
                    "All caught up",
                    systemImage: "checkmark.circle",
                    description: Text("No unknown transactions need a category.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filterItems) { item in
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
                .background(Color(.gray))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            categoryPickerSheet
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategorySheet(
                categoryIndex: categoriesViewModel.categories.count,
                suggestedPredefinedKey: selectedItem?.parsedTransaction.categoryName
            ) { category in
                categoriesViewModel.add(category)
                if let selectedItem {
                    categoriesViewModel.categorizeUncategorized(
                        selectedItem.parsedTransaction,
                        into: category
                    )
                }
                showAddCategorySheet = false
                showCategorySheet = false
                self.selectedItem = nil
            }
            .presentationDetents([.large])
        }
        .navigationTitle("Filter")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var categoryPickerSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if let selectedItem {
                        Text(selectedItem.merchantName)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if categoriesViewModel.categories.isEmpty {
                        Text("Create a category to assign this payment.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(categoriesViewModel.categories) { category in
                            Button {
                                assignCategory(category)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(category.emoji)
                                        .font(.title2)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(category.name)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)

                                        if let key = category.predefinedKey {
                                            Text(key)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        showCategorySheet = false
                        showAddCategorySheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.skyBlue)

                            Text("Create Category")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        showCategorySheet = false
                        selectedItem = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Actions

extension FilterView {
    func deleteItem(_ item: FilterItem) {
        categoriesViewModel.removeUncategorized(item.parsedTransaction)
        if selectedItem?.id == item.id {
            selectedItem = nil
            showCategorySheet = false
        }
    }

    func assignCategory(_ category: Category) {
        guard let selectedItem else { return }

        categoriesViewModel.categorizeUncategorized(
            selectedItem.parsedTransaction,
            into: category
        )

        self.selectedItem = nil
        showCategorySheet = false
    }
}

#Preview {
    NavigationStack {
        FilterView()
    }
    .environment(CategoriesViewModel())
}

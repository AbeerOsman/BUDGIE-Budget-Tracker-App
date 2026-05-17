//
//  AddCategorySheet.swift
//  BUDGIE
//

import SwiftUI

struct AddCategorySheet: View {
    @State private var viewModel: AddCategoryViewModel
    var onSave: (Category) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    init(
        categoryIndex: Int,
        recommendedDailyLimit: Int = 50,
        onSave: @escaping (Category) -> Void
    ) {
        _viewModel = State(
            initialValue: AddCategoryViewModel(
                categoryIndex: categoryIndex,
                recommendedDailyLimit: recommendedDailyLimit
            )
        )
        self.onSave = onSave
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    primaryFieldsSection
                    typeSection
                    budgetSection

                    if viewModel.categoryType == .spending {
                        dailySpendingSection

                        Text("Recommended spending limit: $ \(viewModel.recommendedDailyLimit)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleNavButton(systemImage: "checkmark") {
                        saveCategory()
                    }
                    .opacity(viewModel.canSave ? 1 : 0.4)
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var primaryFieldsSection: some View {
        @Bindable var viewModel = viewModel

        return formSection {
            CategoryFormRow(
                placeholder: "Title",
                text: $viewModel.title,
                sanitize: viewModel.sanitizeTitle
            )

            formDivider

            EmojiFormRow(
                emoji: $viewModel.emoji,
                sanitize: viewModel.sanitizeEmoji
            )
        }
    }

    private var typeSection: some View {
        @Bindable var viewModel = viewModel

        return formSection {
            Text("Type")
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

            formDivider

            CategoryTypeRadioRow(
                title: CategoryType.spending.displayName,
                isSelected: viewModel.categoryType == .spending
            ) {
                viewModel.categoryType = .spending
            }

            CategoryTypeRadioRow(
                title: CategoryType.fixed.displayName,
                isSelected: viewModel.categoryType == .fixed
            ) {
                viewModel.categoryType = .fixed
            }
        }
    }

    private var budgetSection: some View {
        @Bindable var viewModel = viewModel

        return formSection {
            CategoryFormRow(
                placeholder: "Budget",
                text: $viewModel.budget,
                keyboardType: .numberPad,
                sanitize: viewModel.sanitizeDigits,
                showsCurrency: true
            )
        }
    }

    private var dailySpendingSection: some View {
        @Bindable var viewModel = viewModel

        return formSection {
            CategoryFormRow(
                placeholder: "Maximum daily spending",
                text: $viewModel.dailySpending,
                keyboardType: .numberPad,
                sanitize: viewModel.sanitizeDigits,
                showsCurrency: true
            )
        }
    }

    private func formSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(formSectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var formSectionBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGray6)
    }

    private var formDivider: some View {
        Divider()
            .overlay(Color(.separator))
            .padding(.leading, 16)
    }

    private func saveCategory() {
        guard let category = viewModel.buildCategory() else { return }
        onSave(category)
        dismiss()
    }
}

private struct EmojiFormRow: View {
    @Binding var emoji: String
    let sanitize: (String) -> String

    var body: some View {
        HStack(spacing: 12) {
            TextField("Emoji", text: $emoji)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: emoji) { _, newValue in
                    let sanitized = sanitize(newValue)
                    if sanitized != newValue {
                        emoji = sanitized
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct CategoryTypeRadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color("Sky Blue") : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryFormRow: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    let sanitize: (String) -> String
    var showsCurrency: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(keyboardType == .numberPad ? .never : .words)
                .autocorrectionDisabled(keyboardType == .numberPad)
                .onChange(of: text) { _, newValue in
                    let sanitized = sanitize(newValue)
                    if sanitized != newValue {
                        text = sanitized
                    }
                }

            if showsCurrency {
                Text("$")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    AddCategorySheet(categoryIndex: 0) { _ in }
}

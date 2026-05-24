//
//  AddCategorySheet.swift
//  BUDGIE
//

import SwiftUI
import SwiftData

private struct AddCategorySheetConfiguration {
    let mode: AddCategoryViewModel.Mode
    let suggestedPredefinedKey: String?
    let onSave: (Category) -> Void
    let onDelete: (() -> Void)?
}

struct AddCategorySheet: View {
    private let configuration: AddCategorySheetConfiguration

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Query private var incomeItems: [Income]
    @State private var viewModel: AddCategoryViewModel?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    init(
        mode: AddCategoryViewModel.Mode,
        suggestedPredefinedKey: String? = nil,
        onSave: @escaping (Category) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        configuration = AddCategorySheetConfiguration(
            mode: mode,
            suggestedPredefinedKey: suggestedPredefinedKey,
            onSave: onSave,
            onDelete: onDelete
        )
    }

    init(
        nextColorIndex: @escaping (CategoryType) -> Int,
        suggestedPredefinedKey: String? = nil,
        onSave: @escaping (Category) -> Void
    ) {
        self.init(
            mode: .add(nextColorIndex: nextColorIndex),
            suggestedPredefinedKey: suggestedPredefinedKey,
            onSave: onSave,
            onDelete: nil
        )
    }

    private var totalIncome: Double {
        incomeItems
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        Group {
            if let viewModel {
                sheetContent(viewModel: viewModel)
            } else {
                Color.clear
            }
        }
        .onAppear {
            ensureViewModel()
        }
        .onChange(of: totalIncome) { _, newValue in
            viewModel?.updateTotalIncome(newValue)
        }
    }

    private func ensureViewModel() {
        guard viewModel == nil else { return }
        viewModel = AddCategoryViewModel(
            mode: configuration.mode,
            categoriesViewModel: categoriesViewModel,
            totalIncome: totalIncome,
            suggestedPredefinedKey: configuration.suggestedPredefinedKey
        )
    }

    @ViewBuilder
    private func sheetContent(viewModel: AddCategoryViewModel) -> some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    primaryFieldsSection(viewModel: viewModel)
                    typeSection(viewModel: viewModel)
                    budgetSection(viewModel: viewModel)

                    if viewModel.categoryType == .spending {
                        dailySpendingSection(viewModel: viewModel)

                        HStack(spacing: 4) {
                            Text("Recommended spending limit:")
                                .font(BudgieFont.subheadline)

                            CurrencyAmountView(
                                amount: viewModel.recommendedDailyLimit,
                                font: BudgieFont.subheadline,
                                iconSize: 14
                            )
                        }
                        .font(BudgieFont.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    }

                    if viewModel.isEditing {
                        deleteSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleNavButton(systemImage: "checkmark") {
                        saveCategory(viewModel: viewModel)
                    }
                    .opacity(viewModel.canSave ? 1 : 0.4)
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private func primaryFieldsSection(viewModel: AddCategoryViewModel) -> some View {
        @Bindable var viewModel = viewModel

        return formSection {
            predefinedCategoryRow(viewModel: viewModel)

            formDivider

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

    private func predefinedCategoryRow(viewModel: AddCategoryViewModel) -> some View {
        @Bindable var viewModel = viewModel

        return HStack {
            Text("Predefined category")
                .font(BudgieFont.body)
                .foregroundStyle(.secondary)

            Spacer()

            Picker(
                "",
                selection: Binding(
                    get: { viewModel.selectedPredefinedKey ?? "" },
                    set: { viewModel.setPredefinedPickerSelection($0) }
                )
            ) {
                Text("Custom").tag("")
                ForEach(viewModel.predefinedOptions, id: \.self) { name in
                    Text(PredefinedCategoryCatalog.localizedDisplayName(for: name)).tag(name)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .tint(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func typeSection(viewModel: AddCategoryViewModel) -> some View {
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

    private func budgetSection(viewModel: AddCategoryViewModel) -> some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: 8) {
            formSection {
                CategoryFormRow(
                    placeholder: "Budget",
                    text: $viewModel.budget,
                    numericKind: .integer,
                    sanitize: viewModel.sanitizeDigits,
                    showsCurrency: true
                )
            }

            if let message = viewModel.budgetValidationMessage {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            configuration.onDelete?()
            dismiss()
        } label: {
            Text("Delete Category")
                .font(BudgieFont.body.weight(.semibold))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(formSectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func dailySpendingSection(viewModel: AddCategoryViewModel) -> some View {
        @Bindable var viewModel = viewModel

        return formSection {
            CategoryFormRow(
                placeholder: "Maximum daily spending",
                text: $viewModel.dailySpending,
                numericKind: .integer,
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

    private func saveCategory(viewModel: AddCategoryViewModel) {
        guard let category = viewModel.buildCategory() else { return }
        configuration.onSave(category)
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
                    .font(BudgieFont.title3)
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
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var numericKind: BudgieNumericInput.FieldKind?
    let sanitize: (String) -> String
    var showsCurrency: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let numericKind {
                WesternDigitField(
                    placeholder: placeholder,
                    text: $text,
                    kind: numericKind
                )
                .foregroundStyle(.primary)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundStyle(.primary)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .onChange(of: text) { _, newValue in
                        let sanitized = sanitize(newValue)
                        if sanitized != newValue {
                            text = sanitized
                        }
                    }
            }

            if showsCurrency {
                SARIcon(size: 16)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    AddCategorySheet(nextColorIndex: { _ in CategoryStyling.colorIndex(for: 0) }) { _ in }
        .environment(CategoriesViewModel())
}

//
//  AddPaymentSheet.swift
//  BUDGIE
//

import SwiftUI

struct AddPaymentSheet: View {
    @State private var viewModel: AddPaymentViewModel
    var onSave: (CategoryPayment, UUID) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    init(
        mode: AddPaymentViewModel.Mode,
        categories: [Category],
        onSave: @escaping (CategoryPayment, UUID) -> Void
    ) {
        _viewModel = State(
            initialValue: AddPaymentViewModel(
                mode: mode,
                categories: categories
            )
        )
        self.onSave = onSave
    }

    init(
        initialCategoryId: UUID,
        categories: [Category],
        onSave: @escaping (CategoryPayment, UUID) -> Void
    ) {
        self.init(
            mode: .add(initialCategoryId: initialCategoryId),
            categories: categories,
            onSave: onSave
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 16) {
                formCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AddPaymentGlassyIconButton(systemImage: "chevron.left") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.isEditing ? "Edit Payment" : "Add Payment")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AddPaymentGlassyIconButton(systemImage: "checkmark") {
                        savePayment()
                    }
                    .opacity(viewModel.canSave ? 1 : 0.4)
                    .disabled(!viewModel.canSave)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
    }

    private var formCard: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 0) {
            titleFieldRow(text: $viewModel.title, viewModel: viewModel)

            formDivider

            amountFieldRow(text: $viewModel.amount, viewModel: viewModel)

            formDivider

            dateRow(date: $viewModel.date)

            formDivider

            categoryRow(selectedCategoryId: $viewModel.selectedCategoryId, viewModel: viewModel)
        }
        .background(formSectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func titleFieldRow(text: Binding<String>, viewModel: AddPaymentViewModel) -> some View {
        TextField("Title", text: text)
            .foregroundStyle(.primary)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(false)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .onChange(of: text.wrappedValue) { _, newValue in
                let sanitized = viewModel.sanitizeTitle(newValue)
                if sanitized != newValue {
                    text.wrappedValue = sanitized
                }
            }
    }

    private func amountFieldRow(text: Binding<String>, viewModel: AddPaymentViewModel) -> some View {
        TextField("Amount spent", text: text)
            .keyboardType(.numberPad)
            .foregroundStyle(.primary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .onChange(of: text.wrappedValue) { _, newValue in
                let sanitized = viewModel.sanitizeAmount(newValue)
                if sanitized != newValue {
                    text.wrappedValue = sanitized
                }
            }
    }

    private func dateRow(date: Binding<Date>) -> some View {
        HStack {
            Text("Date")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            DatePicker(
                "",
                selection: date,
                displayedComponents: .date
            )
            .labelsHidden()
            .tint(Color("Sky Blue"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func categoryRow(selectedCategoryId: Binding<UUID>, viewModel: AddPaymentViewModel) -> some View {
        HStack {
            Text("Category")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Picker("", selection: selectedCategoryId) {
                ForEach(viewModel.categoryOptions) { category in
                    Text(category.name).tag(category.id)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .tint(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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

    private func savePayment() {
        guard let result = viewModel.buildPayment() else { return }
        onSave(result.payment, result.categoryId)
        dismiss()
    }
}

private struct AddPaymentGlassyIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let vm = CategoriesViewModel()
    vm.categories = [
        Category(
            emoji: "🍕",
            name: "Food & Dining",
            type: .spending,
            spent: 0,
            budget: 200,
            dailyLimit: 50,
            colorIndex: 0
        )
    ]

    return Text("Sheet")
        .sheet(isPresented: .constant(true)) {
            AddPaymentSheet(
                initialCategoryId: vm.categories[0].id,
                categories: vm.categories
            ) { _, _ in }
        }
        .environment(vm)
}

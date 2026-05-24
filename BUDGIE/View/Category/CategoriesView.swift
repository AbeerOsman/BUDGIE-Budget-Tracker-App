//
//  CategoriesView.swift
//  BUDGIE
//

import SwiftUI

struct CategoriesView: View {
    @Environment(CategoriesViewModel.self) private var viewModel
    var onAdd: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddCategory = false
    @State private var selectedCategoryId: UUID?
    @State private var categoryPendingDelete: Category?

    var body: some View {
        Group {
            if viewModel.isEmpty {
                emptyState
            } else {
                categoriesList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleNavButton(systemImage: "chevron.backward") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                CircleNavButton(systemImage: "plus") {
                    showAddCategory = true
                    onAdd?()
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategorySheet(nextColorIndex: viewModel.nextColorIndex(for:)) { category in
                viewModel.add(category)
            }
            .presentationDetents([.large])
        }
        .navigationDestination(item: $selectedCategoryId) { categoryId in
            CategoryDetailView(categoryId: categoryId)
        }
        .alert(
            "Delete Category?",
            isPresented: deleteCategoryAlertIsPresented,
            presenting: categoryPendingDelete
        ) { category in
            Button("Cancel", role: .cancel) {
                categoryPendingDelete = nil
            }
            Button("Delete", role: .destructive) {
                deleteCategory(category)
                categoryPendingDelete = nil
            }
        } message: { category in
            Text(
                String(
                    format: String(localized: "Are you sure you want to delete \"%@\"? This cannot be undone."),
                    category.name
                )
            )
        }
    }

    private var deleteCategoryAlertIsPresented: Binding<Bool> {
        Binding(
            get: { categoryPendingDelete != nil },
            set: { isPresented in
                if !isPresented {
                    categoryPendingDelete = nil
                }
            }
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("box")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(x: -1, y: 1)

            Text("No categories yet")
                .font(BudgieFont.title.weight(.bold))
                .foregroundStyle(.primary)

            Text("Tap the “+” to add a category.")
                .font(BudgieFont.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var categoriesList: some View {
        @Bindable var viewModel = viewModel

        return List {
            Section {
                categoryTypePicker(selectedType: $viewModel.selectedType)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                ForEach(viewModel.filteredCategories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        CategoryListCardView(
                            item: category,
                            iconColor: viewModel.accentColor(for: category),
                            progressFillColor: viewModel.progressFillColor(for: category)
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            categoryPendingDelete = category
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func deleteCategory(_ category: Category) {
        withAnimation {
            viewModel.delete(id: category.id)
            if selectedCategoryId == category.id {
                selectedCategoryId = nil
            }
        }
    }

    private func categoryTypePicker(selectedType: Binding<CategoryType>) -> some View {
        HStack(spacing: 0) {
            ForEach(CategoryType.pickerOrder, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType.wrappedValue = type
                    }
                } label: {
                    Text(type.displayName)
                        .font(BudgieFont.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedType.wrappedValue == type ? typePickerSelectionFill : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(typePickerTrackFill)
        .clipShape(Capsule())
    }

    private var typePickerTrackFill: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGray6)
    }

    private var typePickerSelectionFill: Color {
        colorScheme == .dark
            ? Color(.tertiarySystemGroupedBackground)
            : Color(.systemBackground)
    }
}

private struct CategoryListCardView: View {
    let item: Category
    let iconColor: Color
    let progressFillColor: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconColor)
                        .frame(width: 48, height: 48)

                    Text(item.emoji)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(BudgieFont.headline)
                        .foregroundStyle(.primary)

                    CurrencyRatioView(
                        leading: item.spentAmount,
                        trailing: item.budgetAmount,
                        font: BudgieFont.subheadline,
                        iconSize: 14
                    )
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text(item.progressPercentageText)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            CategoryListProgressBar(
                progress: item.progress,
                fillColor: progressFillColor
            )
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGray6)
    }
}

private struct CategoryListProgressBar: View {
    let progress: Double
    let fillColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.12))

                Capsule()
                    .fill(fillColor)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 6)
    }
}

struct CircleNavButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(BudgieFont.body.weight(.medium))
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CategoriesView()
    }
    .environment(CategoriesViewModel())
}

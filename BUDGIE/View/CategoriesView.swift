//
//  CategoriesView.swift
//  BUDGIE
//

import SwiftUI

struct CategoriesView: View {
    @State private var categories: [CategoryCardItem]
    var onAdd: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddCategory = false
    @State private var selectedType: CategoryType = .spending

    init(categories: [CategoryCardItem] = [], onAdd: (() -> Void)? = nil) {
        _categories = State(initialValue: categories)
        self.onAdd = onAdd
    }

    private var filteredCategories: [CategoryCardItem] {
        categories.filter { $0.type == selectedType }
    }

    var body: some View {
        Group {
            if categories.isEmpty {
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
                CircleNavButton(systemImage: "chevron.left") {
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
            AddCategorySheet(categoryIndex: categories.count) { newCategory in
                categories.append(newCategory)
            }
            .presentationDetents([.large])
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("box")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(x: -1, y: 1)

            Text("No categories yet")
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)

            Text("Tap the “+” to add a category.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var categoriesList: some View {
        ScrollView {
            VStack(spacing: 16) {
                categoryTypePicker
                    .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    ForEach(Array(filteredCategories.enumerated()), id: \.element.id) { index, category in
                        CategoryListCardView(
                            item: category,
                            iconColor: CategoryCardItem.color(forIndex: index)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var categoryTypePicker: some View {
        HStack(spacing: 0) {
            ForEach(CategoryType.pickerOrder, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = type
                    }
                } label: {
                    Text(type.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedType == type ? typePickerSelectionFill : Color.clear)
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

// MARK: - List-style category card (Categories screen)

struct CategoryListCardView: View {
    let item: CategoryCardItem
    var iconColor: Color

    @Environment(\.colorScheme) private var colorScheme

    private var progressFillColor: Color {
        item.progress >= 1 ? .red : iconColor
    }

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
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(budgetLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text(percentageLabel)
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

    private var budgetLabel: String {
        let spent = Int(item.spent)
        let budget = Int(item.budget)
        return "$\(spent) / $\(budget)"
    }

    private var percentageLabel: String {
        let value = item.progress * 100
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "%\(Int(value))"
        }
        return String(format: "%%%.1f", value)
    }
}

// MARK: - List progress bar

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

// MARK: - Circular toolbar button

struct CircleNavButton: View {
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

// MARK: - Previews

#Preview("Empty") {
    NavigationStack {
        CategoriesView(categories: [])
    }
}

#Preview("Spending list") {
    NavigationStack {
        CategoriesView(categories: CategoryCardItem.previewItems)
    }
}

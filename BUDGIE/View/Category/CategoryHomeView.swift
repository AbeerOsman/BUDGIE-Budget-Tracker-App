//
//  CategoryHomeView.swift
//  BUDGIE
//

import SwiftUI

struct CategoryHomeView: View {
    private static let maxDisplayedCategories = 6

    @Environment(\.colorScheme) private var colorScheme
    @Environment(CategoriesViewModel.self) private var viewModel
    @State private var showAllCategories = false
    @State private var showAddCategory = false
    @State private var selectedCategoryId: UUID?

    private let columns = [
        GridItem(.fixed(181), spacing: 12),
        GridItem(.fixed(181), spacing: 12)
    ]

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(alignment: .leading, spacing: 16) {
            header

            if viewModel.isSpendingEmpty {
                categoriesEmptyState
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                    ForEach(displayedCategories) { category in
                        Button {
                            selectedCategoryId = category.id
                        } label: {
                            CategoryCardView(
                                item: category,
                                accentColor: viewModel.accentColor(for: category)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationDestination(isPresented: $showAllCategories) {
            CategoriesView()
        }
        .navigationDestination(item: $selectedCategoryId) { categoryId in
            CategoryDetailView(categoryId: categoryId)
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategorySheet(nextColorIndex: viewModel.nextColorIndex(for:)) { category in
                viewModel.add(category)
            }
            .presentationDetents([.large])
        }
    }

    private var displayedCategories: [Category] {
        Array(viewModel.spendingCategories.prefix(Self.maxDisplayedCategories))
    }

    private var categoriesEmptyState: some View {
        VStack(spacing: 16) {
            Image("box")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(x: -1, y: 1)

            Text("No categories yet")
                .font(BudgieFont.title)
                .foregroundStyle(.primary)

            Button {
                showAddCategory = true
            } label: {
                HStack(spacing: 10) {
                    Text("Add a Category")
                        .font(BudgieFont.body)
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(Color("Sky Blue"))
                            .frame(width: 32, height: 32)

                        Image(systemName: "plus")
                            .font(BudgieFont.body.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Categories")
                .font(BudgieFont.title2)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding(.horizontal, 16)

            Spacer()

            Button {
                showAllCategories = true
            } label: {
                Text("Show All")
                    .font(BudgieFont.body)
                    .foregroundStyle(Color("Sky Blue"))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CategoryCardView: View {
    let item: Category
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 6) {
                Text(item.emoji)
                    .font(BudgieFont.body)

                Text(item.name)
                    .font(BudgieFont.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.85)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(0)

                CurrencyRatioView(
                    leading: item.spentAmount,
                    trailing: item.budgetAmount,
                    font: BudgieFont.caption2.weight(.medium),
                    iconSize: 12,
                    tint: .white.opacity(0.9)
                )
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            }

            CategoryBudgetProgressBar(progress: item.progress)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(width: 181, height: 90)
        .background(accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct CategoryBudgetProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.black.opacity(0.2))

                Capsule()
                    .fill(.white)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CategoryHomeView()
                .padding(.horizontal, 16)
        }
    }
    .environment(CategoriesViewModel())
}

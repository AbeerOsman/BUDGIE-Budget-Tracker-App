//
//  CategoryDetailView.swift
//  BUDGIE
//

import SwiftUI

struct CategoryDetailView: View {
    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let categoryId: UUID

    @State private var showEditSheet = false
    @State private var showAddPayment = false

    private var viewModel: CategoryDetailViewModel {
        CategoryDetailViewModel(
            categoryId: categoryId,
            categoriesViewModel: categoriesViewModel
        )
    }

    var body: some View {
        Group {
            if let category = viewModel.category {
                detailContent(category: category)
            } else {
                ContentUnavailableView("Category not found", systemImage: "folder")
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func detailContent(category: Category) -> some View {
        ZStack(alignment: .top) {
            headerBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    summarySection(category: category)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    recentSection(category: category)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GlassyIconButton(systemImage: "chevron.left") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                GlassyIconButton(systemImage: "plus") {
                    showAddPayment = true
                }
                GlassyTextButton(title: "Edit") {
                    showEditSheet = true
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            AddCategorySheet(mode: .edit(category)) { updated in
                viewModel.updateCategory(updated)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showAddPayment) {
            AddPaymentSheet(
                initialCategoryId: category.id,
                categories: categoriesViewModel.categories
            ) { payment, categoryId in
                categoriesViewModel.addPayment(payment, categoryId: categoryId)
            }
            .presentationDetents([.large])
        }
    }

    private var headerBackground: some View {
        LinearGradient(
            colors: [
                viewModel.accentColor,
                viewModel.accentColor.opacity(0.45),
                Color(.systemBackground)
            ],
            startPoint: UnitPoint(x: 1, y: 0),
            endPoint: UnitPoint(x: 0.04, y: 0.65)
        )
        .mask(alignment: .top) {
            LinearGradient(
                colors: [.white, .white.opacity(0.35), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 550)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .top)
    }

    private func summarySection(category: Category) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(category.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(category.budgetDisplayText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
            }

            CategoryDetailProgressBar(
                progress: category.progress,
                fillColor: viewModel.progressFillColor
            )

            HStack {
                Text(category.spentDisplayText)
                Spacer()
                Text(category.remainingDisplayText)
            }
            .font(.subheadline.weight(.regular))
            .foregroundStyle(.primary)
        }
    }

    private func recentSection(category: Category) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            VStack(spacing: 0) {
                ForEach(viewModel.recentPayments) { payment in
                    CategoryPaymentRow(
                        payment: payment,
                        emoji: category.emoji,
                        iconColor: viewModel.accentColor
                    )

                    if payment.id != viewModel.recentPayments.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(recentListBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var recentListBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGray6)
    }
}

private struct GlassyIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
        }
        .buttonStyle(.plain)
    }
}

private struct GlassyTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryDetailProgressBar: View {
    let progress: Double
    let fillColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.60))

                Capsule()
                    .fill(fillColor)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 8)
    }
}

private struct CategoryPaymentRow: View {
    let payment: CategoryPayment
    let emoji: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor)
                    .frame(width: 44, height: 44)

                Text(emoji)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(payment.merchantName)
                    .font(.body.weight(.regular))
                    .foregroundStyle(.primary)
                    .fontDesign(.rounded)

                Text(payment.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(payment.formattedAmount)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

#Preview {
    let categoriesViewModel = CategoriesViewModel()
    categoriesViewModel.categories = [
        Category(
            emoji: "🍕",
            name: "Food & Dining",
            type: .spending,
            spent: 97,
            budget: 200,
            dailyLimit: 50,
            colorIndex: 0
        )
    ]

    return NavigationStack {
        CategoryDetailView(categoryId: categoriesViewModel.categories[0].id)
    }
    .environment(categoriesViewModel)
}

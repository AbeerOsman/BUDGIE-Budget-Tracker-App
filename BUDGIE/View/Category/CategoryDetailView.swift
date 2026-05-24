//
//  CategoryDetailView.swift
//  BUDGIE
//

import SwiftUI

struct CategoryDetailView: View {
    /// Embedded list rows need an explicit height when nested in `ScrollView`, or new rows stay clipped / zero-sized.
    private static let paymentRowListStride: CGFloat = 70

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let categoryId: UUID

    @State private var showEditSheet = false
    @State private var showAddPayment = false
    @State private var paymentToEdit: CategoryPayment?
    @State private var paymentPendingDelete: CategoryPayment?

    var body: some View {
        @Bindable var store = categoriesViewModel
        let detailVM = CategoryDetailViewModel(
            categoryId: categoryId,
            categoriesViewModel: store
        )

        Group {
            if let category = detailVM.category {
                detailContent(
                    category: category,
                    detailVM: detailVM,
                    store: store
                )
            } else {
                ContentUnavailableView("Category not found", systemImage: "folder")
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func detailContent(
        category: Category,
        detailVM: CategoryDetailViewModel,
        store: CategoriesViewModel
    ) -> some View {
        ZStack(alignment: .top) {
            headerBackground(detailVM: detailVM)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    summarySection(category: category, detailVM: detailVM)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    recentSection(
                        category: category,
                        detailVM: detailVM,
                        store: store
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GlassyIconButton(systemImage: "chevron.backward") {
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
            AddCategorySheet(
                mode: .edit(category),
                onSave: { updated in
                    detailVM.updateCategory(updated)
                },
                onDelete: {
                    store.delete(id: category.id)
                    showEditSheet = false
                    dismiss()
                }
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showAddPayment) {
            AddPaymentSheet(
                initialCategoryId: category.id,
                categories: store.categories
            ) { payment, categoryId in
                store.addPayment(payment, categoryId: categoryId)
            }
            .presentationDetents([.large])
        }
        .sheet(item: $paymentToEdit) { payment in
            AddPaymentSheet(
                mode: .edit(payment),
                categories: store.categories
            ) { updated, _ in
                store.updatePayment(previous: payment, with: updated)
            }
            .presentationDetents([.large])
        }
        .alert(
            "Delete Payment?",
            isPresented: deletePaymentAlertIsPresented,
            presenting: paymentPendingDelete
        ) { payment in
            Button("Cancel", role: .cancel) {
                paymentPendingDelete = nil
            }
            Button("Delete", role: .destructive) {
                store.deletePayment(id: payment.id, categoryId: category.id)
                paymentPendingDelete = nil
            }
        } message: { payment in
            Text(
                String(
                    format: String(localized: "Are you sure you want to delete \"%@\"? This cannot be undone."),
                    payment.merchantName
                )
            )
        }
    }

    private var deletePaymentAlertIsPresented: Binding<Bool> {
        Binding(
            get: { paymentPendingDelete != nil },
            set: { isPresented in
                if !isPresented {
                    paymentPendingDelete = nil
                }
            }
        )
    }

    private func headerBackground(detailVM: CategoryDetailViewModel) -> some View {
        LinearGradient(
            colors: [
                detailVM.accentColor,
                detailVM.accentColor.opacity(0.45),
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

    private func summarySection(
        category: Category,
        detailVM: CategoryDetailViewModel
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(category.name)
                    .font(BudgieFont.largeTitle.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    .foregroundStyle(.primary)

                Spacer()

                CurrencyAmountView(
                    amount: category.budgetAmount,
                    font: BudgieFont.title2,
                    weight: .bold,
                    iconSize: 20
                )
                .foregroundStyle(.primary)
            }

            CategoryDetailProgressBar(
                progress: category.progress,
                fillColor: detailVM.progressFillColor
            )

            HStack {
                LabeledCurrencyView(
                    label: "Spent",
                    amount: category.spentAmount,
                    font: BudgieFont.subheadline,
                    iconSize: 14
                )

                Spacer()

                LabeledCurrencyView(
                    label: "Left",
                    amount: category.remainingAmountInt,
                    font: BudgieFont.subheadline,
                    iconSize: 14
                )
            }
            .foregroundStyle(.primary)
        }
    }

    private func recentSection(
        category: Category,
        detailVM: CategoryDetailViewModel,
        store: CategoriesViewModel
    ) -> some View {
        let payments = detailVM.recentPayments

        return VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(BudgieFont.title2.weight(.bold))
                .foregroundStyle(.primary)

            if !payments.isEmpty {
                List {
                    ForEach(payments) { payment in
                        CategoryPaymentRow(
                            payment: payment,
                            emoji: category.emoji,
                            iconColor: detailVM.accentColor
                        )
                        .overlay(alignment: .bottom) {
                            if payment.id != payments.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(recentListBackground)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: HorizontalEdge.trailing, allowsFullSwipe: false) {
                            Button {
                                paymentToEdit = payment
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.gray)

                            Button(role: .destructive) {
                                paymentPendingDelete = payment
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .environment(\.defaultMinListRowHeight, 68)
                .frame(
                    height: Self.paymentRowListStride * CGFloat(payments.count)
                )
                .id(payments.map(\.id))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
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
                .font(BudgieFont.body.weight(.semibold))
        }
        .buttonStyle(.plain)
    }
}

private struct GlassyTextButton: View {
    let title: LocalizedStringKey
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
                    .font(BudgieFont.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(payment.merchantName)
                    .font(BudgieFont.body.weight(.regular))
                    .foregroundStyle(.primary)
                    .fontDesign(.rounded)

                Text(payment.formattedDate)
                    .font(BudgieFont.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CurrencyAmountView(
                amount: payment.amountValue,
                font: BudgieFont.body,
                weight: .semibold,
                iconSize: 16,
                prefix: "-"
            )
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

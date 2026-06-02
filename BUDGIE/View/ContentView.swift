
//  ContentView.swift
//  BUDGIE
//

import SwiftUI
import SwiftData

struct ContentView: View {
    private enum ResetAlertState: Identifiable {
        case monthlyPrompt
        case resetLaterInfo
        
        var id: Int {
            switch self {
            case .monthlyPrompt: return 1
            case .resetLaterInfo: return 2
            }
        }
    }

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query private var items: [Income]

    @State private var showAddIncome = false
    @State private var resetAlertState: ResetAlertState?

    // MARK: - Income

    var totalIncome: Double {
        items
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Spent

    var totalSpent: Double {
        categoriesViewModel.totalSpentFromPayments
    }

    // MARK: - Remaining

    var remaining: Double {
        totalIncome - totalSpent
    }

    // MARK: - Progress

    var progressPercentage: Double {
        totalIncome > 0 ? totalSpent / totalIncome : 0
    }

    private var primaryIncomeRecord: Income? {
        items
            .filter { $0.type == "income" }
            .sorted { $0.timestamp > $1.timestamp }
            .first
    }

    private var hasUncategorizedTransactions: Bool {
        !categoriesViewModel.uncategorizedTransactions.isEmpty
    }

    private var categoryResetAlertMessage: String {
        guard let income = primaryIncomeRecord else {
            return String(localized: "Today is your monthly date to reset category payments. Do you want to reset all category payments now?")
        }

        let formattedPeriod = CategoryPaymentResetScheduler.formattedIncomePeriod(
            fromDay: income.normalizedSalaryPeriodFromDay,
            toDay: income.normalizedSalaryPeriodToDay
        )
        return String(
            format: String(localized: "Today is your monthly date to reset category payments (based on your income date, %@). Do you want to reset all category payments and clear spending totals?"),
            formattedPeriod
        )
    }

    @Environment(\.colorScheme) private var colorScheme

    var oppositePrimary: Color {
        colorScheme == .dark ? .black : .white
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                LinearGradient(
                    colors: [
                        Color.darkNavy,
                        Color.steelBlue,
                        Color.skyBlue
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .frame(height: 250)
                .ignoresSafeArea(edges: .top)

                LinearGradient(
                    colors: [
                        oppositePrimary.opacity(0.0),
                        oppositePrimary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 250)
                .ignoresSafeArea(edges: .top)

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 16) {

                        // MARK: Income Box

                        if totalIncome == 0 {

                            EmptyIncomeView()

                        } else {

                            FilledIncomeView(
                                income: totalIncome,
                                spent: totalSpent,
                                remaining: remaining,
                                progress: progressPercentage
                            )
                        }

                        // MARK: Insights

                        InsightsView(totalIncome: totalIncome)
                            .padding(.horizontal, 16)

                        // MARK: Categories

                        CategoryHomeView()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 8)
                }
                .toolbar {

                    // MARK: Filter

                    ToolbarItem(
                        placement: .navigationBarTrailing
                    ) {

                        NavigationLink(destination: FilterView()) {
                            FilterToolbarButton(
                                showsBadge: hasUncategorizedTransactions
                            )
                        }
                    }

                    // MARK: Settings

                    ToolbarItem(
                        placement: .navigationBarTrailing
                    ) {

                        NavigationLink(
                            destination:
                                MainSetting()
                        ) {

                            Label(
                                "Setting",
                                systemImage: "gearshape"
                            )
                        }
                    }
                }
            }
        }

        // MARK: Import SMS

        .onAppear {
            categoriesViewModel.budgetAlertTotalIncome = totalIncome
            importSMS()
            refreshMonthlyResetReminder()
            evaluateCategoryResetPrompt()
        }

        .onChange(of: totalIncome) { _, newIncome in
            categoriesViewModel.budgetAlertTotalIncome = newIncome
        }

        // MARK: Import when returning from Shortcuts

        .onChange(of: scenePhase) { _, newPhase in

            if newPhase == .active {

                categoriesViewModel.budgetAlertTotalIncome = totalIncome

                // Reload latest SMS transactions
                categoriesViewModel.reloadTransactionsFromShortcuts()

                refreshMonthlyResetReminder()
                evaluateCategoryResetPrompt()
            }
        }

        .alert(item: $resetAlertState) { state in
            switch state {
            case .monthlyPrompt:
                return Alert(
                    title: Text("Reset Category Payments?"),
                    message: Text(categoryResetAlertMessage),
                    primaryButton: .default(Text("Confirm")) {
                        categoriesViewModel.resetAllCategoryPayments()
                        categoriesViewModel.markCategoryResetConfirmed()
                    },
                    secondaryButton: .cancel(Text("Not Now")) {
                        categoriesViewModel.markCategoryResetDeclined()
                        resetAlertState = .resetLaterInfo
                    }
                )
            case .resetLaterInfo:
                return Alert(
                    title: Text("Reset Category Payments"),
                    message: Text("You can reset category payments anytime from Settings > Reset Category Payments."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }

        // MARK: Sheet

        .sheet(isPresented: $showAddIncome) {
            Text("Add Income")
        }
    }

    // MARK: Import SMS

    private func importSMS() {

        SMSImportService()
            .importSavedTransactions(
                into: categoriesViewModel
            )
    }

    private func refreshMonthlyResetReminder() {
        guard let income = primaryIncomeRecord else {
            BudgieNotificationService.shared.cancelMonthlyResetReminder()
            return
        }
        BudgieNotificationService.shared.scheduleMonthlyResetReminder(
            resetDay: income.normalizedSalaryPeriodToDay
        )
    }

    private func evaluateCategoryResetPrompt() {
        guard let income = primaryIncomeRecord else { return }
        guard categoriesViewModel.hasCategoryPaymentHistory else { return }
        guard categoriesViewModel.shouldPromptForCategoryReset(
            paydayToDay: income.normalizedSalaryPeriodToDay
        ) else {
            return
        }

        resetAlertState = .monthlyPrompt
    }

    // MARK: Delete

    private func deleteItems(offsets: IndexSet) {

        withAnimation {

            for index in offsets {

                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Empty Income State

struct EmptyIncomeView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {

        VStack(spacing: 0) {

            VStack(spacing: 16) {

                Text("Income")
                    .font(BudgieFont.title2)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink {

                    IncomeDetailsView(onSave: {})

                } label: {

                    HStack(spacing: 8) {

                        Text("Add an Income")
                            .font(BudgieFont.body)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)

                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.cyan)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.budgieGroupedBoxBackground(for: colorScheme))
        )
        .overlay(alignment: .topLeading) {
            Image("main")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .offset(x: 34, y: -76)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Filled Income State

struct FilledIncomeView: View {
    @Environment(\.colorScheme) var colorScheme

    var income: Double
    var spent: Double
    var remaining: Double
    var progress: Double

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Header

            HStack(spacing: 16) {

                Text("Income")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.primary)

                Spacer()

                CurrencyAmountView(
                    amount: Int(income),
                    font: .system(size: 22, weight: .bold),
                    iconSize: 22
                )
                .foregroundStyle(.primary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // MARK: Progress Bar

            VStack(spacing: 12) {

                GeometryReader { geometry in

                    ZStack(alignment: .leading) {

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary.opacity(0.12))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            Color(
                                                red: 0.8,
                                                green: 0.2,
                                                blue: 0.2
                                            ),

                                            Color(
                                                red: 0.9,
                                                green: 0.3,
                                                blue: 0.3
                                            )
                                        ]
                                    ),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width:
                                    geometry.size.width
                                    * CGFloat(
                                        min(progress, 1.0)
                                    )
                            )
                    }
                    .frame(height: 6)
                }
                .frame(height: 6)

                // MARK: Info

                HStack(spacing: 0) {

                    LabeledCurrencyView(
                        label: "Spent",
                        amount: Int(spent),
                        font: .system(size: 14),
                        iconSize: 14
                    )
                    .foregroundStyle(.secondary)

                    Spacer()

                    LabeledCurrencyView(
                        label: "Left",
                        amount: Int(remaining),
                        font: .system(size: 14),
                        iconSize: 14
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.budgieGroupedBoxBackground(for: colorScheme))
        )
        .overlay(alignment: .topLeading) {
            Image("main")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .offset(x: 34, y: -76)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
}

#Preview {

    ContentView()
        .modelContainer(
            for: Income.self,
            inMemory: true
        )
        .environment(CategoriesViewModel())
}


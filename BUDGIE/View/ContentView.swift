
//  ContentView.swift
//  BUDGIE
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query private var items: [Income]

    @State private var showAddIncome = false
    @State private var showCategoryResetAlert = false

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
        guard let incomeDate = primaryIncomeRecord?.date else {
            return "Today is your monthly date to reset category payments. Do you want to reset all category payments now?"
        }

        let formattedDay = CategoryPaymentResetScheduler.formattedIncomeDay(incomeDate: incomeDate)
        return "Today is your monthly date to reset category payments (based on your income date, \(formattedDay)). Do you want to reset all category payments and clear spending totals?"
    }

    var body: some View {
        ZStack{
            
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(red: 0.0, green: 0.6, blue: 0.8),   // Cyan
                        Color(red: 0.0, green: 0.2, blue: 0.6),   // Dark Blue
                        Color(red: 0.4, green: 0.1, blue: 0.4)    // Purple
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
        NavigationStack {
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
                    
                    InsightsView()
                        .padding(.horizontal, 16)
                    
                    // MARK: Categories
                    
                    CategoryHomeView()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .padding(.top, 8)
            }
            
            // MARK: Toolbar
            
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
        
    }//Zstack

        // MARK: Import SMS

        .onAppear {
            categoriesViewModel.budgetAlertTotalIncome = totalIncome
            importSMS()
            evaluateCategoryResetPrompt()
        }
        .onChange(of: totalIncome) { _, newIncome in
            categoriesViewModel.budgetAlertTotalIncome = newIncome
        }

        // MARK: Import when returning from Shortcuts

        .onChange(of: scenePhase) { _, newPhase in

            if newPhase == .active {
                categoriesViewModel.budgetAlertTotalIncome = totalIncome
                importSMS()
                evaluateCategoryResetPrompt()
            }
        }
        .alert("Reset Category Payments?", isPresented: $showCategoryResetAlert) {
            Button("Confirm") {
                categoriesViewModel.resetAllCategoryPayments()
                categoriesViewModel.markCategoryResetConfirmed()
            }
            Button("Not Now", role: .cancel) {
                categoriesViewModel.markCategoryResetDeclined()
            }
        } message: {
            Text(categoryResetAlertMessage)
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

    private func evaluateCategoryResetPrompt() {
        guard let incomeDate = primaryIncomeRecord?.date else { return }
        guard categoriesViewModel.hasCategoryPaymentHistory else { return }
        guard categoriesViewModel.shouldPromptForCategoryReset(incomeDate: incomeDate) else {
            return
        }
        showCategoryResetAlert = true
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
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink {

                    IncomeDetailsView(onSave: {})

                } label: {

                    HStack(spacing: 8) {

                        Text("Add an Income")
                            .font(.system(size: 16, weight: .regular))
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

                Text("$\(Int(income))")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
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

                    Text("Spent $\(Int(spent))")
                        .font(
                            .system(
                                size: 14,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("Left $\(Int(remaining))")
                        .font(
                            .system(
                                size: 14,
                                weight: .regular
                            )
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

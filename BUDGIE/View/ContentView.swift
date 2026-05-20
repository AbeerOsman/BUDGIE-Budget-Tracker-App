
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

    // MARK: - Income

    var totalIncome: Double {
        items
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Spent

    var totalSpent: Double {
        items
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Remaining

    var remaining: Double {
        totalIncome - totalSpent
    }

    // MARK: - Progress

    var progressPercentage: Double {
        totalIncome > 0 ? totalSpent / totalIncome : 0
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                // MARK: Income Box

                if totalIncome == 0 {

                    EmptyIncomeView(action: {
                        showAddIncome = true
                    })

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
                    .padding(.bottom, 16)

                // MARK: Categories

                List {

                    Section {

                        CategoryHomeView()
                            .listRowInsets(
                                EdgeInsets(
                                    top: 8,
                                    leading: 16,
                                    bottom: 8,
                                    trailing: 16
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }

            // MARK: Toolbar

            .toolbar {

                // MARK: Filter

                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {

                    NavigationLink(

                        destination:

                            FilterView(

                                items:

                                    categoriesViewModel
                                    .uncategorizedTransactions
                                    .map {

                                        FilterItem(
                                            id: $0.id,

                                            merchantName:
                                                $0.merchantName
                                                ?? "Unknown Merchant",

                                            date:
                                                $0.date.formatted(
                                                    date: .abbreviated,
                                                    time: .shortened
                                                ),

                                            amount:
                                                $0.amount ?? 0,

                                            parsedTransaction: $0
                                        )
                                    }
                            )

                    ) {

                        Label(
                            "Filter unknown transaction",
                            systemImage:
                                "line.3.horizontal.decrease"
                        )
                    }
                }

                // MARK: Settings

                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {

                    NavigationLink(
                        destination:
                            IncomeDetailsView(onSave: {})
                    ) {

                        Label(
                            "Setting",
                            systemImage: "gearshape"
                        )
                    }
                }
            }
        }

        // MARK: Import SMS

        .onAppear {

            importSMS()
        }

        // MARK: Import when returning from Shortcuts

        .onChange(of: scenePhase) { _, newPhase in

            if newPhase == .active {

                importSMS()
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

    var action: () -> Void

    var body: some View {

        VStack(spacing: 0) {

            VStack(spacing: 16) {

                Text("Income")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.white)

                Button(action: action) {

                    HStack(spacing: 8) {

                        Text("Add an Income")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .regular
                                )
                            )
                            .foregroundColor(.gray)

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
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color(
                        red: 0.08,
                        green: 0.08,
                        blue: 0.08
                    )
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Filled Income State

struct FilledIncomeView: View {

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
                    .foregroundColor(.white)

                Spacer()

                Text("$\(Int(income))")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // MARK: Progress Bar

            VStack(spacing: 12) {

                GeometryReader { geometry in

                    ZStack(alignment: .leading) {

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                Color(
                                    red: 0.3,
                                    green: 0.3,
                                    blue: 0.3
                                )
                            )

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
                        .foregroundColor(
                            Color(
                                red: 0.6,
                                green: 0.6,
                                blue: 0.6
                            )
                        )

                    Spacer()

                    Text("Left $\(Int(remaining))")
                        .font(
                            .system(
                                size: 14,
                                weight: .regular
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.6,
                                green: 0.6,
                                blue: 0.6
                            )
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color(
                        red: 0.08,
                        green: 0.08,
                        blue: 0.08
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.cyan.opacity(0.3),
                            lineWidth: 1.5
                        )
                )
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

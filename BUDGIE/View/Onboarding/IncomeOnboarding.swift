//
//  IncomeOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//

import SwiftUI
import SwiftData

struct IncomeOnboarding: View {
    
    @State private var step = 0
    @State private var goToAutomation = false
    @State private var goToMain = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        
        if goToAutomation {
            AutomationOnboarding()
            
        } else if goToMain {
            ContentView()
            
        } else {
            
            ZStack {
                
                Image(colorScheme == .dark ? "DarkBG" : "LightBG")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.75)
                    .offset(x:30,y:-500)
                    .blur(radius: 60)
                
                switch step {
                    
                case 0:
                    IncomeIntroView {
                        withAnimation {
                            step = 1
                        }
                    } onSkip: {
                        withAnimation {
                            goToAutomation = true
                        }
                    }
                    
                case 1:
                    IncomeFormView { title, amount, fromDay, toDay in
                        // Save income to SwiftData
                        let newIncome = Income(
                            title: title,
                            amount: amount,
                            date: Date(),
                            type: "income",
                            salaryPeriodFromDay: fromDay,
                            salaryPeriodToDay: toDay
                        )
                        modelContext.insert(newIncome)
                        
                        do {
                            try modelContext.save()
                        } catch {
                            print("Error saving income: \(error)")
                        }
                        
                        withAnimation {
                            step = 2
                        }
                    }
                    
                default:
                    IncomeReadyView {
                        withAnimation {
                            goToAutomation = true
                        }
                    } onSkip: {
                        withAnimation {
                            hasOnboarded = true
                            goToMain = true
                        }
                    }
                }
            }
            .animation(.easeInOut, value: step)
        }
    }
}

#Preview {
    IncomeOnboarding()
        .modelContainer(for: Income.self, inMemory: true)
}

//
//  IncomeOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//

import SwiftUI
import SwiftData
import UIKit

struct IncomeOnboarding: View {
    
    @State private var currentStep = 0
    @State private var goToMain = false
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        
        if goToMain {
            ContentView()
        } else {
            ZStack {
                Image(colorScheme == .dark ? "DarkBG" : "LightBG")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.75)
                    .offset(x:30,y:-500)
                    .blur(radius: 60)
                
                VStack(spacing: 0) {
                    SetupStepProgress(currentStep: currentStep + 1)
                    
                    TabView(selection: $currentStep) {
                        IncomeFormView(
                            onSave: saveIncomeAndAdvance,
                            onSkip: { goToStep(1) }
                        )
                        .tag(0)
                        
                        AutomationVideoView(
                            onOpenShortcuts: {
                                if let url = URL(string: "https://apps.apple.com/sa/app/shortcuts/id1462947752") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            onNext: { goToStep(2) },
                            onSkip: { goToStep(2) }
                        )
                        .tag(1)
                        
                        WidgetSetupOnboardingView(onFinish: completeOnboarding)
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.35), value: currentStep)
                    .onChange(of: currentStep) { oldStep, newStep in
                        if oldStep != newStep {
                            dismissKeyboard()
                        }
                    }
                }
            }
        }
    }
    
    private func goToStep(_ step: Int) {
        dismissKeyboard()
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = step
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    private func saveIncomeAndAdvance(title: String, amount: Double, fromDay: Int, toDay: Int) {
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
        
        goToStep(1)
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.35)) {
            hasOnboarded = true
            goToMain = true
        }
    }
}

#Preview {
    IncomeOnboarding()
        .modelContainer(for: Income.self, inMemory: true)
}

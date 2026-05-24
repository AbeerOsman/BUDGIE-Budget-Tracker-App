//
//  Onboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 28/11/1447 AH.
//


import SwiftUI

struct Onboarding: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var page = 0
    @State private var showOnboarding2 = false
    
    let titles = [
        String(localized: "Understand Your\nSpending Clearly"),
        String(localized: "Track Expenses\nAutomatically"),
        String(localized: "Build Better\nFinancial Habits")
    ]
    
    let descriptions = [
        String(localized: "Track payments, organize categories, and see where your money goes through simple and meaningful financial insights."),
        String(localized: "Use Apple Pay, bank SMS, shortcuts, and widgets to quickly log and manage your spending with less manual effort."),
        String(localized: "Set your own budgets, monitor category limits, and stay more aware of your spending habits every day.")
    ]
    
    let lightImages = ["charts", "box2", "wallet2"]
    let darkImages = ["chartDark", "box2Dark", "wallet2Dark"]
    
    var currentImages: [String] {
        colorScheme == .dark ? lightImages : darkImages
    }
    
    
    var body: some View {
        
        if showOnboarding2 {
            Onboarding2()
            
        } else {
            
            ZStack {
//                
                Image(colorScheme == .dark ? "DarkBG" : "LightBG")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.75)
                .offset(x:30,y:-500)
                .blur(radius: 60)
                
                VStack {
                    
                    // TOP BUTTON
                    HStack {
                        
                        Spacer()
                        
                        Button(page == 2 ? "Next" : "Skip") {
                            
                            withAnimation {
                                showOnboarding2 = true
                            }
                        }
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .padding()
                    }
                    
                    // PAGES
                    TabView(selection: $page) {
                        
                        ForEach(0..<3) { index in
                            
                            VStack(alignment: .leading) {
                                
                                Spacer()
                                
                                Image(currentImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 250)
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                                
                                Text(titles[index])
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .primary,
                                                .primary,
                                                .mintBlue,
                                                .skyBlue,
                                            ],
                                            startPoint: .bottomLeading,
                                            endPoint: .top
                                        )
                                    )
                                
                                Text(descriptions[index])
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 6)
                            }
                            .padding(.horizontal, 28)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // PAGE CONTROL
                    HStack(spacing: 10) {
                        
                        ForEach(0..<3) { dot in
                            
                            Circle()
                                .fill(
                                    dot == page
                                    ? Color.primary
                                    : Color.secondary.opacity(0.3)
                                )
                                .frame(width: 9, height: 9)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    Onboarding()
}

//
//  Onboarding2.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 28/11/1447 AH.
//
import SwiftUI

struct Onboarding2: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var goToIncomeOnboarding = false
    @State private var goToMain = false
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    
    var body: some View {
        if goToIncomeOnboarding {
            IncomeOnboarding()
        } else if goToMain {
            ContentView()
        } else {
            ZStack {
                
                Image(colorScheme == .dark ? "DarkBG" : "LightBG")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.75)
                    .offset(y: -300)
                    .blur(radius: 5)
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(colorScheme == .dark ? "favicon" : "faviconDark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                        
                        Text("Budgie")
                            .font(BudgieFont.body.weight(.bold))
                    }
                    
                    Text("Achieve Financial\nStability with Ease")
                        .font(BudgieFont.title)
                        .lineSpacing(4)
                        .padding(.top, 20)
                    
                    Text("Track your spending. Real-time affordability insights.")
                        .font(BudgieFont.body)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    
                    Button {
                        withAnimation {
                            goToIncomeOnboarding = true
                        }
                    } label: {
                        Text("Start Setup")
                            .font(BudgieFont.headline.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Sky Blue"))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 34)
                    
                    Button {
                        withAnimation {
                            hasOnboarded = true
                            goToMain = true
                        }
                    } label: {
                        Text("I’ll do it later")
                            .font(BudgieFont.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 36)
                }
                .padding(.horizontal, 28)
            }
        }
    }
}

#Preview {
    Onboarding2()
}

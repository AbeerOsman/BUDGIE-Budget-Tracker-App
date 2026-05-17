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
    
    var body: some View {
        if goToIncomeOnboarding {
            IncomeOnboarding()
        } else if goToMain {
            Main()
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
                            .font(.system(size: 16, weight: .bold))
                    }
                    
                    Text("Achieve Financial\nStability with Ease")
                        .font(.system(size: 36, weight: .bold))
                        .lineSpacing(4)
                        .padding(.top, 20)
                    
                    Text("Track your spending. Real-time affordability insights.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    
                    Button {
                        withAnimation {
                            goToIncomeOnboarding = true
                        }
                    } label: {
                        Text("Start Setup")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Sky Blue"))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 34)
                    
                    Button {
                        withAnimation {
                            goToMain = true
                        }
                    } label: {
                        Text("I’ll do it later")
                            .font(.system(size: 15))
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

//
//  IncomeOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//


import SwiftUI

struct IncomeOnboarding: View {
    
    @State private var step = 0
    @State private var goToAutomation = false
    @State private var goToMain = false
    @Environment(\.colorScheme) var colorScheme

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
                    IncomeFormView {
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
}


// MARK: - SCREEN 1

struct IncomeIntroView: View {
    @Environment(\.colorScheme) var colorScheme
    var onContinue: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Spacer()
            
            VStack(spacing: 18) {
                
                Text("Start With Your Income")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Adding your income helps you set realistic budgets, track your spending more clearly, and better understand your financial habits.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}


// MARK: - SCREEN 2

struct IncomeFormView: View {
    
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @Environment(\.colorScheme) var colorScheme
    var onSave: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Text("Add Your Main Income")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            VStack(spacing: 22) {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    TextField("Title", text: $title)
                        .foregroundColor(.white)
                    
                    Divider()
                        .background(Color.gray.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.numberPad)
                        .foregroundColor(.white)
                    
                    Divider()
                        .background(Color.gray.opacity(0.5))
                }
                
                DatePicker(
                    "Date of Income",
                    selection: $date,
                    displayedComponents: .date
                )
                .colorScheme(colorScheme == .dark ? .dark :.light  )
                .foregroundColor(.primary)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
            .padding(.top, 30)
            
            Text("You can always add other income sources later, whether it's freelance work, rewards, gifts, or any extra earnings.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 30)
                .padding(.top, 30)
            
            Spacer()
            
            Button(action: onSave) {
                Text("Save Income")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Color.skyBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}


// MARK: - SCREEN 3

struct IncomeReadyView: View {
    
    var onContinue: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Spacer()
            
            Image("fly")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            
            VStack(spacing: 18) {
                
                Text("You're Almost Ready")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Great start! Just 2 more quick steps to unlock the complete Budgie experience.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                
                Button(action: onContinue) {
                    Text("Continue Setup")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

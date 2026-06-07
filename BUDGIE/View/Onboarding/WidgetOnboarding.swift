//
//  WidgetOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//

import SwiftUI

// MARK: - Widget Setup

struct WidgetSetupOnboardingView: View {
    
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Quickly View\nYour Spending")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            ScrollView {
                WidgetSetupInstructionsContent(showsHowToTitle: false)
            }
            
            Button(action: onFinish) {
                Text("Finish")
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

#Preview {
    WidgetSetupOnboardingView(onFinish: {})
}

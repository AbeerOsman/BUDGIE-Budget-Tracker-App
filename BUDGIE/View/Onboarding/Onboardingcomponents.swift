//
//  Onboardingcomponents.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 30/11/1447 AH.
//
import SwiftUI

struct SetupStepProgress: View {
    let currentStep: Int
    
    private let steps = ["Income", "Automation", "Shortcut"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Step \(currentStep)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.skyBlue)
            
            HStack(spacing: 6) {
                ForEach(1...3, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Color.skyBlue : Color.gray.opacity(0.18))
                        .frame(height: 6)
                }
            }
            
            Text(steps[currentStep - 1])
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 30)
        .padding(.top, 18)
    }
}

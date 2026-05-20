//
//  InsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 01/12/1447 AH.
//
import SwiftUI

struct InsightsView: View {
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Insights")
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.26)
                .foregroundStyle(.primary)
                .padding(.bottom, 64)

            if viewModel.hasInsights {
                
                // Period Picker
                InsightsPeriodPicker(selected: $viewModel.selectedPeriod)
                
                // Chart حسب الـ period
                switch viewModel.selectedPeriod {
                case .day:
                    Text("Day Chart Coming Soon")
                         .foregroundColor(.primary)
                case .week:
                    Text("Week Chart Coming Soon")
                         .foregroundColor(.primary)
                case .month:
                    Text("Month Chart Coming Soon")
                        .foregroundColor(.primary)
                }

            
            } else {
                Spacer()
                InsightsEmptyState()
                Spacer()
            }

        }
        .padding(16)
        .padding(.bottom, 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.budgieGroupedBoxBackground(for: colorScheme))
        )
    }
}

#Preview {
    InsightsView()
        .padding()
}

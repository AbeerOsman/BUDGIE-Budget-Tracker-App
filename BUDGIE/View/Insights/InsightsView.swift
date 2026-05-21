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
                .foregroundColor(.primary)

            if viewModel.hasInsights {

                InsightsPeriodPicker(
                    selected: $viewModel.selectedPeriod
                )

                switch viewModel.selectedPeriod {

                case .day:

                    DailyInsightsView()

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
        .frame(maxWidth: .infinity)
        .frame(height: 430)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Dark Charcoal"))
        )
    }
}

#Preview {

    ZStack {

        Color("AppBackground")
            .ignoresSafeArea()

        InsightsView()
            .padding()
    }
}

//
//  InsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 01/12/1447 AH.
//
import SwiftUI

struct InsightsView: View {

    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Insights")
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.26)
                .foregroundColor(.primary)
                .padding(.bottom, 64)

            if viewModel.hasInsights {

                Text("Chart Coming Soon")
                    .foregroundColor(.primary)

            } else {

                InsightsEmptyState()

            }
        }
        .padding(16)
        .padding(.bottom, 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Dark Charcoal"))
        )
    }
}

#Preview {
    InsightsView()
        .padding()
}

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

        VStack(alignment: .leading) {

            Text("Insights")
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.26)
                .foregroundColor(.primary)

            Spacer()

            if viewModel.hasInsights {

                Text("Chart Coming Soon")
                    .foregroundColor(.primary)

            } else {

                InsightsEmptyState()

            }

            Spacer()
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
    InsightsView()
        .padding()
}

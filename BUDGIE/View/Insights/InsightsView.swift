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

        VStack(alignment: .leading, spacing: 24) {

            Text("Insights")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            

            if viewModel.hasInsights {

                // chart later
                Text("Chart Coming Soon")
                    .foregroundColor(.primary)

            } else {

                InsightsEmptyState()

            }

        }
        .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, minHeight: 493)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("Dark Charcoal").opacity(1))
        )
    }
}

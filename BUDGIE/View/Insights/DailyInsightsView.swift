//
//  DailyInsightsView.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 04/12/1447 AH.
//
import SwiftUI

struct DailyInsightsView: View {

    @StateObject private var viewModel =
    DailyInsightViewModel()

    var body: some View {

        HStack(spacing: 20) {

            DailyProgressCircle(
                progress: viewModel.progress
            )

            VStack(alignment: .leading, spacing: 6) {

                Text("Spent from budget")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)

                Text(
                    "$\(viewModel.totalSpentToday, specifier: "%.2f") / $\(viewModel.dailyBudget, specifier: "%.0f")"
                )
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(
                                red: 31 / 255,
                                green: 109 / 255,
                                blue: 178 / 255
                            ),
                            Color(
                                red: 63 / 255,
                                green: 175 / 255,
                                blue: 211 / 255
                            )
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }

            Spacer()
        }
        .padding(.top, 12)
    }
}

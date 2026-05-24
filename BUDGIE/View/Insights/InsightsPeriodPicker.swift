//
//  InsightsPeriodPicker.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 03/12/1447 AH.
//
import SwiftUI

struct InsightsPeriodPicker: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selected: InsightsPeriod
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            tabButton("Day", .day)
            tabButton("Week", .week)
            tabButton("Month", .month)
        }
        .padding(4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.03),
                            Color.black.opacity(0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 10, y: 5)
        )
    }

    private func tabButton(_ title: LocalizedStringKey, _ period: InsightsPeriod) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                selected = period
            }
        } label: {
            Text(title)
                .font(selected == period ? BudgieFont.headline : BudgieFont.subheadline)
                .foregroundStyle(
                    selected == period
                    ? Color.primary
                    : Color.secondary
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background {
                    if selected == period {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: colorScheme == .dark
                                    ? [
                                        Color.white.opacity(0.10),
                                        Color.white.opacity(0.03),
                                        Color.black.opacity(0.18)
                                    ]
                                    : [
                                        Color.black.opacity(0.06),
                                        Color.white.opacity(0.65),
                                        Color.black.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

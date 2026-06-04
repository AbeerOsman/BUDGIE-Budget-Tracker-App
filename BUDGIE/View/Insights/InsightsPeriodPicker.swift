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
        .padding(3)
        .background(
            Capsule()
                .fill(backgroundFill)
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }

    private var backgroundFill: some ShapeStyle {
        LinearGradient(
            colors: colorScheme == .dark
            ? [
                Color.white.opacity(0.10),
                Color.white.opacity(0.05),
                Color.black.opacity(0.18)
            ]
            : [
                Color.black.opacity(0.08),
                Color.white.opacity(0.55),
                Color.black.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var selectedFill: some ShapeStyle {
        LinearGradient(
            colors: colorScheme == .dark
            ? [
                Color.white.opacity(0.22),
                Color.white.opacity(0.10),
                Color.black.opacity(0.12)
            ]
            : [
                Color.white.opacity(0.85),
                Color.white.opacity(0.45),
                Color.black.opacity(0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var borderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.20)
        : Color.black.opacity(0.14)
    }

    private var selectedBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.30)
        : Color.white.opacity(0.90)
    }

    private func tabButton(
        _ title: LocalizedStringKey,
        _ period: InsightsPeriod
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                selected = period
            }
        } label: {
            Text(title)
                .font(selected == period ? BudgieFont.headline : BudgieFont.subheadline)
                .foregroundStyle(
                    selected == period
                    ? Color.primary
                    : Color.secondary.opacity(0.85)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .glassEffect()
                .background {
                    if selected == period {
                        Capsule()
                            .fill(selectedFill)
                            .overlay(
                                Capsule()
                                    .stroke(selectedBorderColor, lineWidth: 1)
                            )
                            .shadow(
                                color: .black.opacity(colorScheme == .dark ? 0.28 : 0.12),
                                radius: 8,
                                y: 3
                            )
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

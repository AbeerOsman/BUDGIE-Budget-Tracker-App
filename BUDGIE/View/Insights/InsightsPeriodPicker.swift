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
    @State private var isMoving = false

    var body: some View {
        HStack(spacing: 0) {
            tabButton("Day", .day)
            tabButton("Week", .week)
            tabButton("Month", .month)
        }
        .padding(3)
        .background {
            Capsule()
                .fill(trackColor)
        }
    }

    private var trackColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.10)
        : Color.black.opacity(0.08)
    }

    private var selectedColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.14)
        : Color.black.opacity(0.10)
    }

    private var movingBorder: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.40)
        : Color.white.opacity(0.95)
    }

    private func tabButton(
        _ title: LocalizedStringKey,
        _ period: InsightsPeriod
    ) -> some View {
        Button {
            isMoving = true

            withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                selected = period
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeOut(duration: 0.18)) {
                    isMoving = false
                }
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
                .background {
                    if selected == period {
                        Capsule()
                            .fill(selectedColor)
                            .glassEffect()
                            .shadow(
                                color: isMoving
                                ? Color.white.opacity(colorScheme == .dark ? 0.12 : 0.35)
                                : Color.clear,
                                radius: 8,
                                y: 0
                            )
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


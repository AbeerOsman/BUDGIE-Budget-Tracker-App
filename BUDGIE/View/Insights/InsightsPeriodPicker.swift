//
//  InsightsPeriodPicker.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 03/12/1447 AH.
//

import SwiftUI

struct InsightsPeriodPicker: View {

    @Binding var selected: InsightsPeriod

    var body: some View {

        HStack(spacing: 0) {

            tabButton("Day", .day)

            tabButton("Week", .week)

            tabButton("Month", .month)
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func tabButton(_ title: String,
                           _ period: InsightsPeriod) -> some View {

        Button {

            withAnimation(.spring(response: 0.3,
                                  dampingFraction: 0.8)) {
                selected = period
            }

        } label: {

            Text(title)
                .font(.system(size: 15,
                              weight: selected == period ? .semibold : .medium))
                .foregroundStyle(
                    selected == period ? .white : .gray
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {

                    if selected == period {

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.08)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .matchedGeometryEffect(
                                id: "TAB",
                                in: animation
                            )
                    }
                }
        }
        .buttonStyle(.plain)
    }

    @Namespace private var animation
}
#Preview {

    struct PreviewWrapper: View {

        @State private var selected: InsightsPeriod = .day

        var body: some View {

            ZStack {

                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.08, green: 0.08, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {

                

                    InsightsPeriodPicker(selected: $selected)
                        .padding(.horizontal)
                }
            }
        }
    }

    return PreviewWrapper()
}

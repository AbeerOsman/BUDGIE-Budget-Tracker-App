//
//  DailyProgressCircle.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 04/12/1447 AH.
//
import SwiftUI

struct DailyProgressCircle: View {

    var progress: CGFloat = 0.72

    var body: some View {

        ZStack {

            // Background Circle
            Circle()
                .stroke(
                    Color.primary.opacity(0.08),
                    lineWidth: 18
                )

            // Progress Circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
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
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 18,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    .easeInOut(duration: 1),
                    value: progress
                )
        }
        .frame(width: 120, height: 120)
    }
}

#Preview {

    ZStack {

        Color.black
            .ignoresSafeArea()

        DailyProgressCircle(progress: 0.72)
    }
}

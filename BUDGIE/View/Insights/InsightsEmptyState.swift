//
//  InsightsEmptyState.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 01/12/1447 AH.
//
import SwiftUI

struct InsightsEmptyState: View {

    var body: some View {

        VStack(spacing: 20) {
            Image("ghost")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 88)

            VStack(spacing: 8) {

                Text("No insights yet")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("We’ll show your spending insights once there’s some activity.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

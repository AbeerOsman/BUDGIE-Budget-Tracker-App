//
//  AppLockView.swift
//  BUDGIE
//

import SwiftUI

struct AppLockView: View {
    @Environment(AppLockManager.self) private var appLockManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "faceid")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)

                Text("BUDGIE is Locked")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text(
                    String(
                        format: String(localized: "Use %@ to continue"),
                        appLockManager.biometryName
                    )
                )
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)

                if let message = appLockManager.lastErrorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button("Unlock") {
                    Task {
                        await appLockManager.authenticate()
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(Color("Sky Blue"))
                .clipShape(Capsule())
                .padding(.top, 8)
            }
            .padding(32)
        }
        .onAppear {
            Task {
                await appLockManager.authenticate()
            }
        }
    }
}

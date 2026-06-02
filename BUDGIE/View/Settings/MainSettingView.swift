//
//  MainSetting.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman on 30/11/1447 AH.
//

import SwiftUI
import UIKit

struct MainSetting: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                GeneralSection()
                HelpSection()
                SecuritySection()
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleNavButton(systemImage: "chevron.backward") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - General Section
struct GeneralSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle("General")

            VStack(spacing: 16) {
                // Income Details
                NavigationLink(destination: IncomeDetailsView(onSave: {
                    print("Income saved successfully")
                })) {
                    SettingRow(
                        icon: "wallet.bifold",
                        title: "Income Details",
                        hasChevron: true
                    )
                }

                Divider()
                    .background(Color.gray.opacity(0.5))

                // Notifications - Open System Settings
                SettingRow(
                    icon: "bell.badge",
                    title: "Notifications",
                    hasChevron: false,
                    action: {
                        openSystemSettings(scheme: UIApplication.openSettingsURLString)
                    }
                )

                Divider()
                    .background(Color.gray.opacity(0.5))

                // Language - Open System Settings
                SettingRow(
                    icon: "globe",
                    title: "Language",
                    hasChevron: false,
                    action: {
                        openSystemSettings(scheme: UIApplication.openSettingsURLString)
                    }
                )
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Help Section
struct HelpSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle("Help")

            VStack(spacing: 16) {
                // Setup Shortcut Automation - Open System Settings
                SettingRow(
                    icon: "bolt.circle",
                    title: "Setup Shortcut Automation",
                    hasChevron: false,
                    action: openShortcutsApp
                )

                Divider()
                    .background(Color.gray.opacity(0.5))

                // Setup Widget - Open System Settings
                SettingRow(
                    icon: "square.grid.2x2",
                    title: "Setup Widget",
                    hasChevron: false,
                    action: {
                        openSystemSettings(scheme: UIApplication.openSettingsURLString)
                    }
                )
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Security Section
struct SecuritySection: View {
    private enum SecurityAlertState: Identifiable {
        case confirmReset
        case resetDone
        
        var id: Int {
            switch self {
            case .confirmReset: return 1
            case .resetDone: return 2
            }
        }
    }
    
    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @State private var alertState: SecurityAlertState?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle("Security")

            VStack(spacing: 16) {
                AppLockSettingRow()

                Divider()
                    .background(Color.gray.opacity(0.5))

                // Privacy Policy
                NavigationLink(destination: PrivacyPolicyView()) {
                    SettingRow(
                        icon: "newspaper",
                        title: "Privacy Policy",
                        hasChevron: true
                    )
                }

                Divider()
                    .background(Color.gray.opacity(0.5))

                SettingRow(
                    icon: "arrow.counterclockwise.circle",
                    title: "Reset Category Payments",
                    hasChevron: false,
                    action: {
                        alertState = .confirmReset
                    }
                )
                
                Divider()
                    .background(Color.gray.opacity(0.5))

                // Delete Data
                NavigationLink(destination: DeleteDataView()) {
                    SettingRow(
                        icon: "eraser.trianglebadge.exclamationmark",
                        title: "Delete Data",
                        hasChevron: true
                    )
                }
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
        }
        .alert(item: $alertState) { state in
            switch state {
            case .confirmReset:
                return Alert(
                    title: Text("Reset Category Payments?"),
                    message: Text("This will clear spending totals for all categories. You can continue adding new payments right away."),
                    primaryButton: .destructive(Text("Reset Now")) {
                        categoriesViewModel.resetAllCategoryPayments()
                        categoriesViewModel.markCategoryResetConfirmed()
                        alertState = .resetDone
                    },
                    secondaryButton: .cancel()
                )
            case .resetDone:
                return Alert(
                    title: Text("Reset Category Payments"),
                    message: Text("Category payments were reset successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - Reusable Components
struct SectionTitle: View {
    let title: LocalizedStringKey

    init(_ title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 22, weight: .bold))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
    }
}

struct SettingRow: View {
    let icon: String
    let title: LocalizedStringKey
    let hasChevron: Bool
    var action: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(systemName: icon)
                .colorScheme(colorScheme == .dark ? .dark : .light)
                .foregroundColor(.primary)

            Text(title)
                .colorScheme(colorScheme == .dark ? .dark : .light)
                .foregroundColor(.primary)

            Spacer()

            if hasChevron {
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            action?()
        }
    }
}

// MARK: - App Lock Row

struct AppLockSettingRow: View {
    @Environment(AppLockManager.self) private var appLockManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var isOn = false
    @State private var showError = false

    var body: some View {
        HStack {
            Image(systemName: "faceid")
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("App Lock")
                    .foregroundColor(.primary)

                Text(appLockManager.biometryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .onAppear {
            isOn = appLockManager.isEnabled
        }
        .onChange(of: isOn) { _, newValue in
            guard newValue != appLockManager.isEnabled else { return }
            Task {
                let success = await appLockManager.setEnabled(newValue)
                if !success {
                    isOn = appLockManager.isEnabled
                    showError = true
                }
            }
        }
        .alert("App Lock", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let message = appLockManager.lastErrorMessage {
                Text(message)
            } else {
                Text("Could not update App Lock. Try again.")
            }
        }
    }
}

// MARK: - External apps & settings

func openShortcutsApp() {
    if let url = URL(string: "shortcuts://") {
        UIApplication.shared.open(url)
    }
}

func openSystemSettings(scheme: String) {
    if let url = URL(string: scheme) {
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack {
        MainSetting()
    }
    .environment(AppLockManager())
}

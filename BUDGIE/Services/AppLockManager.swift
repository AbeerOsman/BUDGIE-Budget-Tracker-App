//
//  AppLockManager.swift
//  BUDGIE
//

import Foundation
import LocalAuthentication
import Observation

@Observable
final class AppLockManager {
    private let enabledKey = "budgie.appLock.enabled"

    var isUnlocked = false
    var lastErrorMessage: String?

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    var biometryName: String {
        let context = LAContext()
        switch context.biometryType {
        case .faceID:
            return String(localized: "Face ID")
        case .touchID:
            return String(localized: "Touch ID")
        case .opticID:
            return String(localized: "Optic ID")
        default:
            return String(localized: "Biometrics")
        }
    }

    var canUseBiometrics: Bool {
        var error: NSError?
        let context = LAContext()
        return context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
    }

    func lockIfEnabled() {
        guard isEnabled else { return }
        isUnlocked = false
    }

    @MainActor
    func authenticate() async -> Bool {
        lastErrorMessage = nil
        let context = LAContext()
        context.localizedCancelTitle = String(localized: "Cancel")

        let policy: LAPolicy = canUseBiometrics
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        do {
            let success = try await context.evaluatePolicy(
                policy,
                localizedReason: String(localized: "Unlock BUDGIE to access your budget")
            )
            isUnlocked = success
            return success
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .systemCancel, .appCancel:
                lastErrorMessage = nil
            case .biometryNotAvailable:
                lastErrorMessage = String(localized: "Face ID is not available on this device.")
            case .biometryNotEnrolled:
                lastErrorMessage = String(localized: "Set up Face ID in Settings to use App Lock.")
            case .biometryLockout:
                lastErrorMessage = String(localized: "Face ID is locked. Unlock your device and try again.")
            default:
                lastErrorMessage = error.localizedDescription
            }
            return false
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func setEnabled(_ enabled: Bool) async -> Bool {
        if enabled {
            let success = await authenticate()
            if success {
                isEnabled = true
            }
            return success
        } else {
            let success = await authenticate()
            if success {
                isEnabled = false
                isUnlocked = true
            }
            return success
        }
    }

    @MainActor
    func unlockIfNeeded() async {
        guard isEnabled, !isUnlocked else { return }
        _ = await authenticate()
    }
}

//
//  AppSessionController.swift
//  BUDGIE
//

import Foundation
import Observation

/// Controls the app root flow (Splash → Onboarding → Home).
@Observable
final class AppSessionController {
    static let hasOnboardedKey = "hasOnboarded"

    /// Changing this remounts `Splash` from a clean state.
    var rootSessionID = UUID()

    func restartAsNewUser() {
        UserDefaults.standard.set(false, forKey: Self.hasOnboardedKey)
        rootSessionID = UUID()
    }
}

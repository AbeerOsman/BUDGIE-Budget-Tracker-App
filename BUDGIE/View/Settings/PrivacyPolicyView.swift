//
//  PrivacyPolicyView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman on 30/11/1447 AH.
//

import SwiftUI

struct PrivacyPolicyView: View {

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 24) {

                // Title
                VStack(alignment: .leading, spacing: 8) {

                    Text("Privacy Policy")
                        .font(BudgieFont.title)

                    Text("Effective Date: May 25, 2026")
                        .font(BudgieFont.subheadline)
                        .foregroundColor(.gray)

                }
                .padding(.horizontal, 20)

                // Main Card
                VStack(alignment: .leading, spacing: 24) {

                    Text("Welcome to BUDGIE. Your privacy and data security are important to us. This Privacy Policy explains how our application accesses, uses, stores, and protects your information.")
                        .font(BudgieFont.subheadline)
                        .foregroundColor(.gray)

                    // MARK: - Section 1

                    policySection(
                        title: "1. Overview",
                        description: String(localized: "privacy.overview")
                    )

                    // MARK: - Section 2

                    policySection(
                        title: "2. Use of Apple Shortcuts and SMS Data",
                        description: String(localized: "privacy.shortcuts")
                    )

                    // MARK: - Section 3

                    policySection(
                        title: "3. Data Storage and Ownership",
                        description: String(localized: "privacy.storage")
                    )

                    // MARK: - Section 4

                    policySection(
                        title: "4. No Data Selling or Sharing",
                        description: String(localized: "privacy.no_selling")
                    )

                    // MARK: - Section 5

                    policySection(
                        title: "5. User Responsibility",
                        description: String(localized: "privacy.responsibility")
                    )

                    // MARK: - Section 6

                    policySection(
                        title: "6. Security",
                        description: String(localized: "privacy.security")
                    )

                    // MARK: - Section 7

                    policySection(
                        title: "7. Changes to This Privacy Policy",
                        description: String(localized: "privacy.changes")
                    )

                    // MARK: - Section 8

                    policySection(
                        title: "8. Contact",
                        description: String(localized: "privacy.contact")
                    )
                }
                .padding(20)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)

                Spacer(minLength: 30)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Reusable Section

    @ViewBuilder
    func policySection(title: LocalizedStringKey, description: String) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(BudgieFont.body.weight(.semibold))

            Text(description)
                .font(BudgieFont.subheadline)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

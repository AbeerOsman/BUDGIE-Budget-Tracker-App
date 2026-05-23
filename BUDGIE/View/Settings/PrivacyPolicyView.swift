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
                        description:
"""
BUDGIE is a personal budgeting and expense tracking application designed to help users monitor and organize their financial activities. To provide certain features, the app may use Apple Shortcuts automation to identify and process banking SMS notifications related to transactions and expenses.

Our goal is strictly to help users track their spending and financial activity in a simple and secure way.
"""
                    )

                    // MARK: - Section 2

                    policySection(
                        title: "2. Use of Apple Shortcuts and SMS Data",
                        description:
"""
BUDGIE uses Apple Shortcuts solely as a user-enabled automation tool to access and process banking SMS notifications on the user’s device.

The application only extracts limited transaction-related information necessary for expense tracking, including:

• Merchant name
• Transaction amount
• Transaction date and time
• Basic transaction details relevant to budgeting

BUDGIE does not access, collect, monitor, or store unrelated SMS content, personal conversations, passwords, authentication codes, or sensitive personal communications.

The app does not attempt to gain unauthorized access to user data, banking systems, or private information beyond the transaction details intentionally processed through the user’s configured Shortcut automation.
"""
                    )

                    // MARK: - Section 3

                    policySection(
                        title: "3. Data Storage and Ownership",
                        description:
"""
All transaction data processed by BUDGIE is stored locally on the user’s device using Apple technologies such as SwiftData.

If iCloud synchronization is enabled, synchronization occurs securely through Apple CloudKit and is associated only with the user’s personal Apple iCloud account.

BUDGIE developers do not have access to:

• User banking messages
• Transaction history
• Financial records
• Personal SMS content
• iCloud data
• User databases

We do not maintain external servers containing user financial information.

Users remain the sole owners and controllers of their data.
"""
                    )

                    // MARK: - Section 4

                    policySection(
                        title: "4. No Data Selling or Sharing",
                        description:
"""
BUDGIE does not:

• Sell user data
• Share financial information with third parties
• Use transaction data for advertising
• Use personal data for analytics beyond core app functionality
• Store user financial records on external company servers

The data processed by the app is used exclusively to provide budgeting, expense tracking, and financial organization features within the application.
"""
                    )

                    // MARK: - Section 5

                    policySection(
                        title: "5. User Responsibility",
                        description:
"""
By enabling Apple Shortcuts integrations and using BUDGIE features, users acknowledge and accept that:

• They voluntarily configure and authorize the Shortcut automation
• They understand how Apple Shortcuts accesses SMS notifications on their device
• They are responsible for reviewing and managing their device permissions and Shortcut settings

BUDGIE operates only within the permissions explicitly granted by the user and Apple’s system framework.
"""
                    )

                    // MARK: - Section 6

                    policySection(
                        title: "6. Security",
                        description:
"""
We prioritize user privacy and rely on Apple’s secure ecosystem and local device storage technologies to help protect user information.

While we take reasonable measures to support secure data handling, users are responsible for maintaining the security of their own devices, Apple accounts, and access credentials.
"""
                    )

                    // MARK: - Section 7

                    policySection(
                        title: "7. Changes to This Privacy Policy",
                        description:
"""
We may update this Privacy Policy from time to time to reflect improvements, legal requirements, or feature updates. Continued use of the application after updates constitutes acceptance of the revised policy.
"""
                    )

                    // MARK: - Section 8

                    policySection(
                        title: "8. Contact",
                        description:
"""
If you have any questions regarding this Privacy Policy, how BUDGIE handles data, or any other inquiries, please leave a comment through the App Store Reviews section.
"""
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
    func policySection(title: String, description: String) -> some View {

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

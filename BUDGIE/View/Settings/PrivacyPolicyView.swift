//
//  PrivacyPolicyView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 30/11/1447 AH.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Data Protection")
                        .font(.system(size: 16, weight: .semibold))
                    Text("We protect your personal data in accordance with applicable laws and regulations.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    Text("Information Collection")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.top, 16)
                    Text("We collect information to provide and improve our services.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    PrivacyPolicyView()
}

//
//  DeleteDataView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 30/11/1447 AH.
//

import SwiftUI

struct DeleteDataView: View {
    @State private var showConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Delete Data")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Warning")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                    Text("Deleting your data is permanent and cannot be undone. All your information will be removed from our servers.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)

                Button(action: { showConfirmation = true }) {
                    Text("Delete All Data")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .alert("Confirm Deletion", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle data deletion here
            }
        } message: {
            Text("Are you sure you want to permanently delete all your data? This action cannot be undone.")
        }
    }
}

#Preview {
    DeleteDataView()
}

//
//  DeleteDataView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 30/11/1447 AH.
//

import SwiftUI
import SwiftData

struct DeleteDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    @Environment(AppLockManager.self) private var appLockManager
    @Environment(AppSessionController.self) private var appSessionController

    @State private var showConfirmation = false
    @State private var isDeleting = false
    @State private var showError = false
    @State private var errorMessage = ""

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

                    Text(
                        "This permanently removes all data stored on this device: income, categories, payments, uncategorized transactions, shortcut imports, merchant mappings, and insights. This cannot be undone."
                    )
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                }
                .padding(20)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)

                Button(action: { showConfirmation = true }) {
                    Group {
                        if isDeleting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Delete All Data")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .disabled(isDeleting)
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
                performDeletion()
            }
        } message: {
            Text("Are you sure you want to permanently delete all your data on this device?")
        }
        .alert("Could Not Delete Data", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func performDeletion() {
        isDeleting = true
        do {
            try AppDataDeletionService.deleteAllUserData(
                modelContext: modelContext,
                categoriesViewModel: categoriesViewModel,
                appLockManager: appLockManager
            )
            isDeleting = false
            appSessionController.restartAsNewUser()
        } catch {
            isDeleting = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        DeleteDataView()
    }
    .modelContainer(for: Income.self, inMemory: true)
    .environment(CategoriesViewModel())
    .environment(AppLockManager())
    .environment(AppSessionController())
}

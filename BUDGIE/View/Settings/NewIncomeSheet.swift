//
//  NewIncome.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 02/12/1447 AH.
//

import SwiftUI

struct NewIncomeSheet: View {
    @State private var amount = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("New Income")
                .font(.caption)
                .foregroundColor(.gray)

            TextField("0.00", text: $amount)
                .foregroundColor(.primary)
        }.padding(25)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.08))
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .toolbar {
                //Add button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FilterView()) {
                        Label("Add New Income", systemImage: "checkmark")
                    }
                }
            }
        
    }
}

#Preview {
    NewIncomeSheet()
}

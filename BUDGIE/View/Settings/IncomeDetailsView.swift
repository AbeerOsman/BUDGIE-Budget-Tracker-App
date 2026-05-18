//
//  IncomeDetailsView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman on 30/11/1447 AH.
//

import SwiftUI

struct IncomeDetailsView: View {
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
//                Text("Add Your Main Income")
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                    .padding(.top, 20)
                
                VStack(spacing: 22) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        TextField("Title", text: $title)
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                    }
                    
                    DatePicker(
                        "Date of Income",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .colorScheme(colorScheme == .dark ? .dark : .light)
                    .foregroundColor(.primary)
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.gray.opacity(0.08))
                )
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                Text("You can always add other income sources later, whether it's freelance work, gifts, or any extra earnings by + button at the top ")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 350)
                
                Spacer()
                
                Button(action: onSave) {
                    Text("Save Income")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 30)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Income Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    IncomeDetailsView(onSave: {})
}

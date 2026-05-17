////
////  wasanTestView.swift
////  BUDGIE
////
////  Created by wasan jayid althagafi on 26/11/1447 AH.
////
//
//import SwiftUI
//
//struct wasanTestView: View {
//    
//    @State private var transactions: [ParsedTransaction] = []
//    private let service = ShortcutService()
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                if transactions.isEmpty {
//                    Text("No SMS transactions yet")
//                        .foregroundStyle(.secondary)
//                } else {
//                    ForEach(transactions) { transaction in
//                        VStack(alignment: .leading, spacing: 10) {
//                            
//                            Text(transaction.merchantName ?? "Unknown Merchant")
//                                .font(.headline)
//                            
//                            Text("Amount: \(transaction.amount?.description ?? "Unknown") SAR")
//                                .font(.subheadline)
//                            
//                            Text("Category: \(transaction.categoryName ?? "Uncategorized")")
//                                .font(.subheadline)
//                                .foregroundStyle(transaction.categoryName == nil ? .orange : .green)
//                            
//                            Text("Date: \(transaction.date.formatted(date: .abbreviated, time: .shortened))")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                            
//                            Text(transaction.rawMessage)
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        }
//                        .padding(.vertical, 8)
//                    }
//                }
//            }
//            .navigationTitle("SMS Transactions")
//            .toolbar {
//                Button("Refresh") {
//                    loadTransactions()
//                }
//                
//                Button("Clear") {
//                    service.clearTransactions()
//                    loadTransactions()
//                }
//            }
//            .onAppear {
//                loadTransactions()
//            }
//        }
//    }
//    
//    private func loadTransactions() {
//        transactions = service.getSavedTransactions()
//    }
//}
//
//
//#Preview {
//    wasanTestView()
//}
//
//



//
//  wasanTestView.swift
//  BUDGIE
//

import SwiftUI

struct wasanTestView: View {
    
    @State private var transactions: [ParsedTransaction] = []
    private let service = ShortcutService()
    
    // العمليات المصنفة فقط
    private var categorizedTransactions: [ParsedTransaction] {
        transactions.filter { $0.categoryName != nil }
    }
    
    // العمليات غير المصنفة
    private var uncategorizedTransactions: [ParsedTransaction] {
        transactions.filter { $0.categoryName == nil }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                // زر يوديك صفحة الفلتر
                NavigationLink {
                    FilterView(items: uncategorizedTransactions.map {
                        FilterItem(
                            merchantName: $0.merchantName ?? "Unknown Merchant",
                            date: $0.date.formatted(date: .abbreviated, time: .shortened),
                            amount: $0.amount ?? 0
                        )
                    })
                } label: {
                    HStack {
                        Text("Uncategorized")
                        
                        Spacer()
                        
                        Text("\(uncategorizedTransactions.count)")
                            .foregroundStyle(.orange)
                    }
                }
                
                if categorizedTransactions.isEmpty {
                    Text("No categorized SMS transactions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(categorizedTransactions) { transaction in
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text(transaction.merchantName ?? "Unknown Merchant")
                                .font(.headline)
                            
                            Text("Amount: \(transaction.amount?.description ?? "Unknown") SAR")
                                .font(.subheadline)
                            
                            Text("Category: \(transaction.categoryName ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                            
                            Text("Date: \(transaction.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(transaction.rawMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("SMS Transactions")
            .toolbar {
                Button("Refresh") {
                    loadTransactions()
                }
                
                Button("Clear") {
                    service.clearTransactions()
                    loadTransactions()
                }
            }
            .onAppear {
                loadTransactions()
            }
        }
    }
    
    private func loadTransactions() {
        transactions = service.getSavedTransactions()
    }
}

#Preview {
    wasanTestView()
}

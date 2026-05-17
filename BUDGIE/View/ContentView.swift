//
//  ContentView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 20/11/1447 AH.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            List {
                if !items.isEmpty {
                    Section {
                        ForEach(items) { item in
                            NavigationLink {
                                Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            } label: {
                                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }

                Section {
                    CategoryHomeView()
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environment(CategoriesViewModel())
}

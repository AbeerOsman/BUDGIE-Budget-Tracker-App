//
//  CategoryHomeView.swift
//  BUDGIE
//
//  Created by Lojaen Jehad Ayash on 30/11/1447 AH.
//

import SwiftUI

// MARK: - Reusable home section

struct CategoryHomeView: View {
    var categories: [CategoryCardItem]

    private let columns = [
        GridItem(.fixed(181), spacing: 12),
        GridItem(.fixed(181), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(categories) { category in
                    CategoryCardView(item: category)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Categories")
                .font(.custom("SF Pro Display", size: 22).weight(.bold))

            Spacer()

            NavigationLink {
                CategoriesView(categories: categories)
            } label: {
                Text("Show All")
                    .font(.custom("SF Pro Rounded", size: 17))
                    .foregroundStyle(Color("Sky Blue"))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Category card

struct CategoryCardView: View {
    let item: CategoryCardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top, spacing: 6) {

                Text(item.emoji)
                    .font(.system(size: 16))

                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 4)

                Text(budgetLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            CategoryBudgetProgressBar(progress: item.progress)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(width: 181, height: 90)
        .background(item.color)
       // .background(Color("Sky Blue"))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private var budgetLabel: String {
        let spent = Int(item.spent)
        let budget = Int(item.budget)

        return "$\(spent) / $\(budget)"
    }
}

// MARK: - Progress bar

struct CategoryBudgetProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(.black.opacity(0.2))

                Capsule()
                    .fill(.white)
                    .frame(
                        width: geometry.size.width * progress
                    )
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        ScrollView {
            CategoryHomeView(
                categories: CategoryCardItem.previewItems
            )
            .padding(.horizontal, 16)
        }
    }
}

#Preview("Show All → empty") {
    NavigationStack {
        ScrollView {
            CategoryHomeView(categories: [])
                .padding(.horizontal, 16)
        }
    }
}

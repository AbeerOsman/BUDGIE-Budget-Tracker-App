//
//  CategoryStyling.swift
//  BUDGIE
//

import SwiftUI

enum CategoryStyling {
    private static let palette: [Color] = [
        .darkNavy,
        .skyBlue,
        .lime,
        .mintBlue,
        .steelBlue
    ]

    static func colorIndex(for position: Int) -> Int {
        position % palette.count
    }

    static func color(forIndex index: Int) -> Color {
        palette[index % palette.count]
    }
}

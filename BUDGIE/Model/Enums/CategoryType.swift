//
//  CategoryType.swift
//  BUDGIE
//
//  Created by lojaen  on 22/11/1447 AH.
//

import Foundation
enum CategoryType: String, Codable, CaseIterable {
    case spending
    case fixed

    var displayName: String {
        switch self {
        case .spending: String(localized: "Spending")
        case .fixed: String(localized: "Fixed")
        }
    }

    static let pickerOrder: [CategoryType] = [.spending, .fixed]
}

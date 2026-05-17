//
//  Filter.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 27/11/1447 AH.
//

import Foundation
struct FilterItem: Identifiable {
    let id = UUID()
    let merchantName: String
    let date: String
    let amount: Double
}

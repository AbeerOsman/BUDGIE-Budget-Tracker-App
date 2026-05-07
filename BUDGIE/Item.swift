//
//  Item.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 20/11/1447 AH.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

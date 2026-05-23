//
//  BudgieWidgetBundle.swift
//  BudgieWidget
//
//  Created by Ruba Alghamdi on 07/12/1447 AH.
//

import WidgetKit
import SwiftUI

@main
struct BudgieWidgetBundle: WidgetBundle {
    var body: some Widget {
        BudgetWidget()
        BudgieWidgetControl()
        BudgieWidgetLiveActivity()
    }
}

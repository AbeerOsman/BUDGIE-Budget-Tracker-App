//
//  InsightViewModel.swift
//  BUDGIE
//
//  Created by Raghad Aljuid on 01/12/1447 AH.
//
import Foundation
import Combine

enum InsightsPeriod{
    case day, week, month
}

final class InsightsViewModel: ObservableObject {
    @Published var hasInsights: Bool = false
    @Published var selectedPeriod: InsightsPeriod = .day
}

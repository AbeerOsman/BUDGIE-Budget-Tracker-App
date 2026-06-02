//
//  Item.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 01/12/1447 AH.
//

import Foundation
//
//  Item.swift
//  BUDGIE
//

import Foundation
import SwiftData

@Model
final class Income {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date
    
    /// Salary period "from" day, within a month (1...31).
    /// Stored as a day-of-month independent of year/month.
    /// If a value wasn't set yet (e.g. older app versions), this may be `0`.
    var salaryPeriodFromDay: Int = 0
    
    /// Salary period "to" day, within a month (1...31).
    /// Stored as a day-of-month independent of year/month.
    /// If a value wasn't set yet (e.g. older app versions), this may be `0`.
    var salaryPeriodToDay: Int = 0
    var type: String // "income" or "expense"
    var category: String?
    var notes: String?
    var timestamp: Date
    
    init(
        title: String,
        amount: Double,
        date: Date,
        type: String,
        category: String? = nil,
        notes: String? = nil,
        salaryPeriodFromDay: Int? = nil,
        salaryPeriodToDay: Int? = nil,
        timestamp: Date = Date()
    ) {
        let calendar = Calendar.current
        let fallbackDay = calendar.component(.day, from: date)
        
        let rawFromDay = salaryPeriodFromDay ?? fallbackDay
        let rawToDay = salaryPeriodToDay ?? fallbackDay
        
        let (normalizedFromDay, normalizedToDay) = Income.normalizeSalaryPeriod(fromDay: rawFromDay, toDay: rawToDay)
        
        self.title = title
        self.amount = amount
        // For backward compatibility, `date` is still used by reset/notification scheduling.
        // We treat the period end (`salaryPeriodToDay`) as the "payday/reset day".
        self.salaryPeriodFromDay = normalizedFromDay
        self.salaryPeriodToDay = normalizedToDay
        self.date = Income.paydayDate(for: normalizedToDay, referenceDate: date, calendar: calendar)
        self.type = type
        self.category = category
        self.notes = notes
        self.timestamp = timestamp
    }
    
    /// Normalized (and fallback-based) salary period days.
    /// - Returns: `(fromDay, toDay)` with `fromDay <= toDay`.
    private func normalizedSalaryPeriodDays(
        calendar: Calendar = .current
    ) -> (fromDay: Int, toDay: Int) {
        let fallbackDay = calendar.component(.day, from: date)
        
        let rawFrom = salaryPeriodFromDay > 0 ? salaryPeriodFromDay : fallbackDay
        let rawTo = salaryPeriodToDay > 0 ? salaryPeriodToDay : fallbackDay
        
        return Income.normalizeSalaryPeriod(fromDay: rawFrom, toDay: rawTo)
    }
    
    var normalizedSalaryPeriodFromDay: Int {
        normalizedSalaryPeriodDays().fromDay
    }
    
    var normalizedSalaryPeriodToDay: Int {
        normalizedSalaryPeriodDays().toDay
    }
    
    /// Clamp `1...31` and ensure `fromDay <= toDay`.
    private static func normalizeSalaryPeriod(
        fromDay: Int,
        toDay: Int
    ) -> (fromDay: Int, toDay: Int) {
        let clampedFrom = min(max(fromDay, 1), 31)
        let clampedTo = min(max(toDay, 1), 31)
        if clampedFrom <= clampedTo {
            return (clampedFrom, clampedTo)
        } else {
            return (clampedTo, clampedFrom)
        }
    }
    
    /// Creates a real `Date` for scheduling purposes using the provided reference date's year/month.
    /// The day is clamped to the reference month length to avoid invalid dates.
    private static func paydayDate(
        for paydayDay: Int,
        referenceDate: Date,
        calendar: Calendar
    ) -> Date {
        let daysInMonth = calendar.range(of: .day, in: .month, for: referenceDate)?.count ?? 31
        let effectiveDay = min(max(paydayDay, 1), daysInMonth)
        
        var components = calendar.dateComponents([.year, .month], from: referenceDate)
        components.day = effectiveDay
        
        return calendar.date(from: components) ?? referenceDate
    }
}

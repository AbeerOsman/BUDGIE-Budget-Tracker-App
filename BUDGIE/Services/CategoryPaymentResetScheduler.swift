//
//  CategoryPaymentResetScheduler.swift
//  BUDGIE
//

import Foundation

enum CategoryPaymentResetScheduler {
    /// Monthly period key, e.g. `2026-5`, so confirm/decline applies once per calendar month.
    static func periodIdentifier(for date: Date, calendar: Calendar = .current) -> String {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return "\(year)-\(month)"
    }

    /// True when today's day-of-month matches the configured reset day (handles short months).
    static func isResetDayToday(
        resetDay: Int,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        let todayDay = calendar.component(.day, from: today)
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 31
        
        let effectiveResetDay = min(max(resetDay, 1), daysInMonth)
        return todayDay == effectiveResetDay
    }
    
    /// Backward-compatible overload: reset day derived from the income date's day component.
    static func isResetDayToday(
        incomeDate: Date,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        let incomeDay = calendar.component(.day, from: incomeDate)
        return isResetDayToday(resetDay: incomeDay, today: today, calendar: calendar)
    }

    static func formattedIncomeDay(
        incomeDate: Date,
        calendar: Calendar = .current
    ) -> String {
        incomeDate.formatted(.dateTime.month(.wide).day())
    }
    
    /// Formats the currently configured salary period range (e.g. `27-31`).
    /// - Note: This is intended for user-facing messaging, not for scheduling.
    static func formattedIncomePeriod(
        fromDay: Int,
        toDay: Int,
        calendar: Calendar = .current
    ) -> String {
        let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 31
        let effectiveFrom = min(max(fromDay, 1), daysInMonth)
        let effectiveTo = min(max(toDay, 1), daysInMonth)
        
        if effectiveFrom <= effectiveTo {
            return "\(effectiveFrom)-\(effectiveTo)"
        } else {
            return "\(effectiveTo)-\(effectiveFrom)"
        }
    }
}

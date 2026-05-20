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

    /// True when today's day-of-month matches the income date (handles short months).
    static func isResetDayToday(
        incomeDate: Date,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        let incomeDay = calendar.component(.day, from: incomeDate)
        let todayDay = calendar.component(.day, from: today)
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 31

        let effectiveIncomeDay = min(incomeDay, daysInMonth)
        return todayDay == effectiveIncomeDay
    }

    static func formattedIncomeDay(
        incomeDate: Date,
        calendar: Calendar = .current
    ) -> String {
        incomeDate.formatted(
            .dateTime.month(.wide).day()
        )
    }
}

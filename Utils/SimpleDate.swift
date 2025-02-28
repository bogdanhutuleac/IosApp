import Foundation

struct SimpleDate: Equatable, Hashable {
    let year: Int
    let month: Int
    let dayOfMonth: Int
    
    static func now() -> SimpleDate {
        let calendar = Calendar.current
        let date = Date()
        return SimpleDate(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date) - 1, // Swift uses 1-based months, we'll use 0-based to match Android
            dayOfMonth: calendar.component(.day, from: date)
        )
    }
    
    static func fromDate(_ date: Date) -> SimpleDate {
        let calendar = Calendar.current
        return SimpleDate(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date) - 1,
            dayOfMonth: calendar.component(.day, from: date)
        )
    }
    
    static func fromMillis(_ millis: TimeInterval) -> SimpleDate {
        let date = Date(timeIntervalSince1970: millis / 1000.0)
        return fromDate(date)
    }
    
    func toStartOfDay() -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month + 1 // Convert back to 1-based month
        components.day = dayOfMonth
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func toEndOfDay() -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month + 1 // Convert back to 1-based month
        components.day = dayOfMonth
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func toMillis() -> TimeInterval {
        let date = toDate()
        return date.timeIntervalSince1970 * 1000.0
    }
    
    func toDate() -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month + 1 // Convert back to 1-based month
        components.day = dayOfMonth
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func toString() -> String {
        return String(format: "%04d-%02d-%02d", year, month + 1, dayOfMonth)
    }
} 
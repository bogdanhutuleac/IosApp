import Foundation

struct TimeEntry: Equatable, Hashable {
    let hour: Int
    let minute: Int
    
    func toString() -> String {
        // Special case for 24:00/00:00 and 24:30/00:30
        switch (hour, minute) {
        case (24, 0), (0, 0):
            return "00:00"
        case (24, 30), (0, 30):
            return "00:30"
        default:
            return String(format: "%02d:%02d", hour, minute)
        }
    }
    
    func toComparableMinutes() -> Int {
        switch (hour, minute) {
        // Convert 00:00 to represent end of day (24:00)
        case (0, 0):
            return 24 * 60
        // Convert 00:30 to represent 24:30
        case (0, 30):
            return 24 * 60 + 30
        default:
            return hour * 60 + minute
        }
    }
} 
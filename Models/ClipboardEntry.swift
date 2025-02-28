import Foundation

struct ClipboardEntry: Identifiable {
    let id = UUID()
    let content: String
    let deliveryAddress: String
    let subtotal: Double
    let total: Double
    var isPaid: Bool
    let phoneNumber: String
    let maskingCode: String
    let timestamp: Date
    
    init(content: String, deliveryAddress: String, subtotal: Double, total: Double = 0.0, isPaid: Bool = false, phoneNumber: String = "", maskingCode: String = "", timestamp: Date = Date()) {
        self.content = content
        self.deliveryAddress = deliveryAddress
        self.subtotal = subtotal
        self.total = total
        self.isPaid = isPaid
        self.phoneNumber = phoneNumber
        self.maskingCode = maskingCode
        self.timestamp = Self.adjustTimestampForLateNight(timestamp)
    }
    
    static func adjustTimestampForLateNight(_ date: Date) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // If time is between 00:00 and 00:30, adjust to previous day at 23:59:59
        if hour == 0 && minute <= 30 {
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            components.day = (components.day ?? 1) - 1
            components.hour = 23
            components.minute = 59
            components.second = 59
            
            return calendar.date(from: components) ?? date
        }
        
        return date
    }
} 
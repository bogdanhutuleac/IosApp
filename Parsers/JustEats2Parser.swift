import Foundation

class JustEats2Parser: ReceiptParser {
    // Configurable phone number - could be moved to settings
    private let defaultPhoneNumber: String
    
    init(defaultPhoneNumber: String = "") {
        self.defaultPhoneNumber = defaultPhoneNumber
    }
    
    func canParse(lines: [String]) -> Bool {
        return lines.contains { $0.range(of: "JustEats", options: .caseInsensitive) != nil }
    }
    
    func parse(lines: [String]) -> ClipboardEntry? {
        do {
            var deliveryAddress = ""
            var subtotal = 0.0
            var isPaid = false  // Default to false, will be set to true if payment is confirmed
            var maskingCode = ""
            var phoneNumber = defaultPhoneNumber
            
            // Find sections and extract data
            for i in 0..<lines.count {
                let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if line.caseInsensitiveCompare("Order Price") == .orderedSame && i + 1 < lines.count {
                    // Extract subtotal from Order Price
                    let nextLine = lines[i + 1]
                    subtotal = extractAmount(from: nextLine)
                } else if line.lowercased().hasPrefix("paid amount") {
                    let amountString = line.components(separatedBy: "€").last ?? "0.0"
                    let amount = extractAmount(from: amountString)
                    isPaid = amount > 0
                } else if line.range(of: "Outstanding", options: .caseInsensitive) != nil {
                    let amountString = line.components(separatedBy: "€").last ?? "0.0"
                    let amount = extractAmount(from: amountString)
                    if amount > 0 {
                        isPaid = false
                    } else {
                        // If Outstanding is 0.00, consider it paid
                        isPaid = true
                    }
                } else if line.range(of: "Order Paid", options: .caseInsensitive) != nil ||
                          line.range(of: "Order paid", options: .caseInsensitive) != nil ||
                          line.caseInsensitiveCompare("Paid") == .orderedSame {
                    isPaid = true
                } else if line.lowercased().hasPrefix("code)") && i + 1 < lines.count {
                    maskingCode = line.replacingOccurrences(of: "code)", with: "", options: .caseInsensitive)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    deliveryAddress = lines[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.range(of: "(masking code)", options: .caseInsensitive) != nil {
                    // For lines like "01 483 2993 (masking code) 517616386 Knockard Dundrum Road..."
                    let parts = line.components(separatedBy: "(masking")
                    if parts.count == 2 {
                        // Extract phone number if present
                        if let phonePattern = try? NSRegularExpression(pattern: "\\d{2}\\s*\\d{3}\\s*\\d{4}") {
                            let phoneMatches = phonePattern.matches(in: parts[0], range: NSRange(parts[0].startIndex..., in: parts[0]))
                            if let match = phoneMatches.first, let range = Range(match.range, in: parts[0]) {
                                phoneNumber = parts[0][range].replacingOccurrences(of: " ", with: "")
                            }
                        }
                        
                        let afterMasking = parts[1].components(separatedBy: "code)").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let components = afterMasking.components(separatedBy: " ")
                        maskingCode = components.first ?? ""
                        deliveryAddress = afterMasking.replacingOccurrences(of: maskingCode, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }
            
            // Only create the entry if we found an address
            if !deliveryAddress.isEmpty {
                return ClipboardEntry(
                    content: lines.joined(separator: "\n"),
                    deliveryAddress: deliveryAddress,
                    subtotal: subtotal,
                    total: 0.0,
                    isPaid: isPaid,
                    phoneNumber: phoneNumber,
                    maskingCode: maskingCode
                )
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Error parsing JustEats receipt: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractAmount(from string: String) -> Double {
        return Double(string.replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
    }
} 
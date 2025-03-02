import Foundation

class SanMarinoParser: ReceiptParser {
    func canParse(lines: [String]) -> Bool {
        return lines.contains { $0.range(of: "SAN MARINO", options: .caseInsensitive) != nil }
    }
    
    func parse(lines: [String]) -> ClipboardEntry? {
        do {
            var deliveryAddress = ""
            var subtotal = 0.0
            var total = 0.0
            var isPaid = false
            var phoneNumber = ""
            
            // Find sections and extract data
            for i in 0..<lines.count {
                let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Extract address (usually after phone number)
                if line.hasPrefix("+") && line.contains("353") && i > 0 && i < lines.count - 2 {
                    phoneNumber = line
                    // Address is usually the lines before the phone number
                    let addressLines = [lines[i-2], lines[i-1]]
                    deliveryAddress = addressLines.joined(separator: ", ").trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Extract subtotal
                if line.lowercased().hasPrefix("subtotal:") && i + 1 < lines.count {
                    let nextLine = lines[i + 1]
                    subtotal = extractAmount(from: nextLine)
                }
                
                // Extract total
                if line.lowercased().hasPrefix("total:") && i + 1 < lines.count {
                    let nextLine = lines[i + 1]
                    total = extractAmount(from: nextLine)
                }
                
                // Check if paid
                if line.lowercased().contains("payment: paid") || 
                   line.lowercased().contains("paid") {
                    isPaid = true
                }
            }
            
            // If we couldn't find an address but have a phone number, use a default address
            if deliveryAddress.isEmpty && !phoneNumber.isEmpty {
                deliveryAddress = "Address not found"
            }
            
            // Only create the entry if we found an address or phone number
            if !deliveryAddress.isEmpty || !phoneNumber.isEmpty {
                return ClipboardEntry(
                    content: lines.joined(separator: "\n"),
                    deliveryAddress: deliveryAddress,
                    subtotal: subtotal,
                    total: total,
                    isPaid: isPaid,
                    phoneNumber: phoneNumber,
                    maskingCode: ""
                )
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Error parsing San Marino receipt: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractAmount(from string: String) -> Double {
        let amountString = string.replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(amountString) ?? 0.0
    }
} 
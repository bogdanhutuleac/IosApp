import Foundation

protocol ReceiptParser {
    /// Determines if this parser can handle the given receipt content
    func canParse(lines: [String]) -> Bool
    
    /// Parses the receipt content into a ClipboardEntry
    /// Returns nil if parsing fails or the content is not valid for this parser
    func parse(lines: [String]) -> ClipboardEntry?
} 
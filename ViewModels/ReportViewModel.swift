import Foundation
import SwiftUI
import Combine

class ReportViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var clipboardEntries: [ClipboardEntry] = []
    @Published var selectedDate: SimpleDate = SimpleDate.now()
    @Published var morningDeliveries: Int = 0
    @Published var eveningDeliveries: Int = 0
    @Published var totalDeliveries: Int = 0
    @Published var morningTotal: Double = 0.0
    @Published var eveningTotal: Double = 0.0
    @Published var grandTotal: Double = 0.0
    @Published var unpaidCount: Int = 0
    
    // Time thresholds for morning/evening classification
    private let morningStartTime = TimeEntry(hour: 9, minute: 0)   // 9:00 AM
    private let morningEndTime = TimeEntry(hour: 17, minute: 0)    // 5:00 PM
    
    // Parsers for different receipt formats
    private var parsers: [ReceiptParser] = []
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize parsers
        parsers = [
            JustEats2Parser(defaultPhoneNumber: "014832993")
            // Add other parsers as needed
        ]
        
        // Set up clipboard monitoring
        setupClipboardMonitoring()
    }
    
    // MARK: - Clipboard Monitoring
    
    private func setupClipboardMonitoring() {
        #if os(iOS)
        // Set up notification for when app becomes active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                // Check clipboard when app becomes active
                self?.checkClipboard()
            }
            .store(in: &cancellables)
        #endif
    }
    
    #if os(iOS)
    private func checkClipboard() {
        // Only suggest processing if clipboard contains text
        if let clipboardString = UIPasteboard.general.string, !clipboardString.isEmpty {
            // Here we could show an alert or notification to the user
            // For now, we'll just log it
            print("Clipboard contains text that might be a receipt")
        }
    }
    #endif
    
    // Method to manually process clipboard content
    func processClipboardContent(_ content: String) {
        let lines = content.components(separatedBy: .newlines)
        
        // Try each parser until one succeeds
        for parser in parsers {
            if parser.canParse(lines: lines) {
                if let entry = parser.parse(lines: lines) {
                    // Add the entry and update calculations
                    addEntry(entry)
                    return
                }
            }
        }
        
        // If we get here, no parser could handle the content
        print("No parser could handle the clipboard content")
    }
    
    // MARK: - Entry Management
    
    private func addEntry(_ entry: ClipboardEntry) {
        // Check if this is a duplicate entry
        if !clipboardEntries.contains(where: { $0.content == entry.content }) {
            clipboardEntries.append(entry)
            updateCalculations()
        }
    }
    
    func clearEntries() {
        clipboardEntries.removeAll()
        updateCalculations()
    }
    
    // MARK: - Calculations
    
    func updateCalculations() {
        // Filter entries for the selected date
        let entriesForDate = clipboardEntries.filter { entry in
            let entryDate = SimpleDate.fromDate(entry.timestamp)
            return entryDate == selectedDate
        }
        
        // Reset counters
        morningDeliveries = 0
        eveningDeliveries = 0
        morningTotal = 0.0
        eveningTotal = 0.0
        unpaidCount = 0
        
        // Process each entry
        for entry in entriesForDate {
            let entryTime = getTimeFromDate(entry.timestamp)
            
            if isMorningDelivery(entryTime) {
                morningDeliveries += 1
                morningTotal += entry.subtotal
            } else {
                eveningDeliveries += 1
                eveningTotal += entry.subtotal
            }
            
            if !entry.isPaid {
                unpaidCount += 1
            }
        }
        
        // Update totals
        totalDeliveries = morningDeliveries + eveningDeliveries
        grandTotal = morningTotal + eveningTotal
    }
    
    private func getTimeFromDate(_ date: Date) -> TimeEntry {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return TimeEntry(hour: hour, minute: minute)
    }
    
    private func isMorningDelivery(_ time: TimeEntry) -> Bool {
        // Check if the time is between morning start and end times
        return time.toComparableMinutes() >= morningStartTime.toComparableMinutes() &&
               time.toComparableMinutes() < morningEndTime.toComparableMinutes()
    }
    
    // MARK: - Date Navigation
    
    func goToPreviousDay() {
        let calendar = Calendar.current
        if let date = selectedDate.toDate(),
           let previousDay = calendar.date(byAdding: .day, value: -1, to: date) {
            selectedDate = SimpleDate.fromDate(previousDay)
            updateCalculations()
        }
    }
    
    func goToNextDay() {
        let calendar = Calendar.current
        if let date = selectedDate.toDate(),
           let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
            selectedDate = SimpleDate.fromDate(nextDay)
            updateCalculations()
        }
    }
    
    func goToToday() {
        selectedDate = SimpleDate.now()
        updateCalculations()
    }
} 
import SwiftUI

struct ReportScreen: View {
    @EnvironmentObject var viewModel: ReportViewModel
    @State private var showingClipboardInput = false
    @State private var clipboardText = ""
    @State private var showingTotalDetails = false
    
    // Formatters for localization
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                // Date navigation
                HStack {
                    Button(action: viewModel.goToPreviousDay) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Button(action: viewModel.goToToday) {
                        Text(formatDate(viewModel.selectedDate))
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Button(action: viewModel.goToNextDay) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding()
                
                // Summary cards
                HStack(spacing: 16) {
                    SummaryCard(
                        title: "Morning",
                        deliveries: viewModel.morningDeliveries,
                        total: viewModel.morningTotal,
                        currencyFormatter: currencyFormatter
                    )
                    
                    SummaryCard(
                        title: "Evening",
                        deliveries: viewModel.eveningDeliveries,
                        total: viewModel.eveningTotal,
                        currencyFormatter: currencyFormatter
                    )
                }
                .padding(.horizontal)
                
                // Total card (tappable to show details)
                Button(action: { showingTotalDetails = true }) {
                    TotalCard(
                        deliveries: viewModel.totalDeliveries,
                        total: viewModel.grandTotal,
                        unpaidCount: viewModel.unpaidCount,
                        currencyFormatter: currencyFormatter
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Entries list
                List {
                    ForEach(entriesForSelectedDate) { entry in
                        NavigationLink(destination: ReceiptDetailView(entry: entry)) {
                            EntryRow(entry: entry, currencyFormatter: currencyFormatter)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Delivery Calculator", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: viewModel.clearEntries) {
                    Text("Clear")
                },
                trailing: Button(action: { showingClipboardInput = true }) {
                    Image(systemName: "doc.on.clipboard")
                }
            )
        }
        .sheet(isPresented: $showingClipboardInput) {
            ClipboardInputView(
                clipboardText: $clipboardText,
                onSubmit: {
                    viewModel.processClipboardContent(clipboardText)
                    clipboardText = ""
                    showingClipboardInput = false
                }
            )
        }
        .sheet(isPresented: $showingTotalDetails) {
            TotalDetailsView(
                morningDeliveries: viewModel.morningDeliveries,
                morningTotal: viewModel.morningTotal,
                eveningDeliveries: viewModel.eveningDeliveries,
                eveningTotal: viewModel.eveningTotal,
                totalDeliveries: viewModel.totalDeliveries,
                grandTotal: viewModel.grandTotal,
                unpaidCount: viewModel.unpaidCount,
                currencyFormatter: currencyFormatter
            )
        }
    }
    
    // Helper to format the date
    private func formatDate(_ date: SimpleDate) -> String {
        let dateObj = date.toDate()
        return dateFormatter.string(from: dateObj)
    }
    
    // Computed property to get entries for the selected date
    private var entriesForSelectedDate: [ClipboardEntry] {
        viewModel.clipboardEntries.filter { entry in
            let entryDate = SimpleDate.fromDate(entry.timestamp)
            return entryDate == viewModel.selectedDate
        }
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
    let title: String
    let deliveries: Int
    let total: Double
    let currencyFormatter: NumberFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(deliveries)")
                .font(.system(size: 36, weight: .bold))
            
            Text(currencyFormatter.string(from: NSNumber(value: total)) ?? "€0.00")
                .font(.title3)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TotalCard: View {
    let deliveries: Int
    let total: Double
    let unpaidCount: Int
    let currencyFormatter: NumberFormatter
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(deliveries)")
                    .font(.system(size: 36, weight: .bold))
                
                if unpaidCount > 0 {
                    Text("\(unpaidCount) unpaid")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Text(currencyFormatter.string(from: NSNumber(value: total)) ?? "€0.00")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EntryRow: View {
    let entry: ClipboardEntry
    let currencyFormatter: NumberFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.deliveryAddress)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Text(currencyFormatter.string(from: NSNumber(value: entry.subtotal)) ?? "€0.00")
                    .foregroundColor(.green)
                
                Spacer()
                
                if entry.isPaid {
                    Text("PAID")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                } else {
                    Text("UNPAID")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
                
                if !entry.maskingCode.isEmpty {
                    Text(entry.maskingCode)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ClipboardInputView: View {
    @Binding var clipboardText: String
    let onSubmit: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSample: Int? = nil
    
    // Sample receipts for easy testing
    private let sampleReceipts = [
        "JustEats Receipt": """
        Delivery 133803766
        
        JustEats
        
        Due: 2025-02-26 21:50
        
        Delivery Station 2
        
        Qty
        
        1
        
        1
        
        Item
        
        Price
        
        Taco Chips
        
        €7.99
        
        Doner Kebab
        
        €8.99
        
        - Extra Meat
        
        €2.00
        
        Order Price
        
        €18.98
        
        Service Charges
        
        €0.99
        
        Delivery Charges
        
        €3.90
        
        Net Price
        
        €23.87
        
        Paid Amount
        
        €23.87
        
        Outstanding
        
        €0.00
        
        Customer Details
        
        Monika Warchala
        
        01 483 2993 (masking
        
        code) 303844006
        
        84 Weston Park Dublin 14 Dublin 14 D14 WD28
        
        Order Paid
        """,
        "San Marino Receipt": """
        SAN MARINO
        
        Dundrum
        
        Placed: 20.02.2025, 17:31:26
        
        Accepted: 20.02.2025, 17:31:40
        
        11 Grange Wood
        
        Rathfarnha
        
        +353879188373
        
        1x Chicken Burger Chips and Sauce
        
        : 8.50.
        
        Mayonaise
        
        1x 12" Margherita & Drink Fanta (can)
        
        € 10.70
        
        1x Garlic Chips & Cheese
        
        € 6.40
        
        1x Chicken Wings
        
        6.90
        
        1x 4 Chicken Tenders
        
        € 4.50
        
        1x Sausage Meal Diet Coke (Can)
        
        € 9.00
        
        1x Oreo Milkshake
        
        € 4.20
        
        1x Vanila Milkshake
        
        € 3.90
        
        2x Cans
        
        € 4.00
        
        Type: Diet Coke
        
        Subtotal:
        
        € 58.10
        
        Delivery:
        
        € 3.00
        
        Total:
        
        € 61.10
        
        Payment: Paid
        
        Signed By
        """
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Sample receipt selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(sampleReceipts.keys.enumerated()), id: \.element) { index, key in
                            Button(action: {
                                clipboardText = sampleReceipts[key] ?? ""
                                selectedSample = index
                            }) {
                                Text(key)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedSample == index ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedSample == index ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            #if os(iOS)
                            if let clipboardString = UIPasteboard.general.string {
                                clipboardText = clipboardString
                            }
                            #endif
                            selectedSample = nil
                        }) {
                            Text("Paste from Clipboard")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedSample == nil ? Color.blue : Color(.systemGray5))
                                .foregroundColor(selectedSample == nil ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                
                TextEditor(text: $clipboardText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding()
                
                Button(action: onSubmit) {
                    Text("Process Receipt")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(clipboardText.isEmpty)
            }
            .navigationBarTitle("Paste Receipt", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct TotalDetailsView: View {
    let morningDeliveries: Int
    let morningTotal: Double
    let eveningDeliveries: Int
    let eveningTotal: Double
    let totalDeliveries: Int
    let grandTotal: Double
    let unpaidCount: Int
    let currencyFormatter: NumberFormatter
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Morning")) {
                    DetailRow(title: "Deliveries", value: "\(morningDeliveries)")
                    DetailRow(title: "Total", value: currencyFormatter.string(from: NSNumber(value: morningTotal)) ?? "€0.00")
                }
                
                Section(header: Text("Evening")) {
                    DetailRow(title: "Deliveries", value: "\(eveningDeliveries)")
                    DetailRow(title: "Total", value: currencyFormatter.string(from: NSNumber(value: eveningTotal)) ?? "€0.00")
                }
                
                Section(header: Text("Summary")) {
                    DetailRow(title: "Total Deliveries", value: "\(totalDeliveries)")
                    DetailRow(title: "Grand Total", value: currencyFormatter.string(from: NSNumber(value: grandTotal)) ?? "€0.00")
                    if unpaidCount > 0 {
                        DetailRow(title: "Unpaid Orders", value: "\(unpaidCount)", valueColor: .red)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Daily Summary", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.semibold)
        }
    }
}

struct ReportScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReportScreen()
            .environmentObject(ReportViewModel())
    }
} 
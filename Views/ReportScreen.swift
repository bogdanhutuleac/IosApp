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
                        EntryRow(entry: entry, currencyFormatter: currencyFormatter)
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
    
    var body: some View {
        NavigationView {
            VStack {
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
import SwiftUI

struct ReceiptDetailView: View {
    let entry: ClipboardEntry
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Receipt Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(dateFormatter.string(from: entry.timestamp))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(entry.isPaid ? "PAID" : "UNPAID")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(entry.isPaid ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .foregroundColor(entry.isPaid ? .green : .red)
                            .cornerRadius(4)
                        
                        if !entry.maskingCode.isEmpty {
                            Text("Code: \(entry.maskingCode)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Financial details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Financial Details")
                        .font(.headline)
                    
                    Divider()
                    
                    DetailRow(title: "Subtotal", value: currencyFormatter.string(from: NSNumber(value: entry.subtotal)) ?? "€0.00")
                    
                    DetailRow(title: "Total", value: currencyFormatter.string(from: NSNumber(value: entry.total)) ?? "€0.00")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Customer details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Customer Details")
                        .font(.headline)
                    
                    Divider()
                    
                    DetailRow(title: "Address", value: entry.deliveryAddress)
                    
                    if !entry.phoneNumber.isEmpty {
                        DetailRow(title: "Phone", value: entry.phoneNumber)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Raw receipt
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original Receipt")
                        .font(.headline)
                    
                    Divider()
                    
                    Text(entry.content)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Receipt Details")
    }
}

// Preview provider for SwiftUI canvas
struct ReceiptDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReceiptDetailView(entry: ClipboardEntry(
                content: "Sample receipt content...",
                deliveryAddress: "123 Main St, Dublin",
                subtotal: 18.99,
                total: 23.87,
                isPaid: true,
                phoneNumber: "01 483 2993",
                maskingCode: "303844006"
            ))
        }
    }
} 
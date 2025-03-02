import SwiftUI

struct AllReceiptsView: View {
    @EnvironmentObject var viewModel: ReportViewModel
    @State private var showingClipboardInput = false
    @State private var clipboardText = ""
    
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
        NavigationView {
            List {
                ForEach(viewModel.clipboardEntries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                    NavigationLink(destination: ReceiptDetailView(entry: entry)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.deliveryAddress)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text(dateFormatter.string(from: entry.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
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
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("All Receipts", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: viewModel.clearEntries) {
                    Text("Clear All")
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
    }
}

struct AllReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        AllReceiptsView()
            .environmentObject(ReportViewModel())
    }
} 
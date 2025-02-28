import SwiftUI

@main
struct DeliveryCalculatoriOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ReportViewModel())
        }
    }
} 
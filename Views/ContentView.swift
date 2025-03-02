import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        TabView {
            ReportScreen()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            AllReceiptsView()
                .tabItem {
                    Label("Receipts", systemImage: "list.bullet.rectangle")
                }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
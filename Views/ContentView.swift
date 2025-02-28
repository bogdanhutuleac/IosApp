import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        ReportScreen()
            .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
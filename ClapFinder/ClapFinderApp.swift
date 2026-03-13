import SwiftUI

@main
struct ClapFinderApp: App {
    @StateObject private var viewModel = ClapFinderViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}

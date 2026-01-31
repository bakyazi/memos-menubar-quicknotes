import SwiftUI

@main
struct MemosMenuBarApp: App {
    @StateObject private var viewModel = MemoViewModel()
    @State private var showSettings = false
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel, showSettings: $showSettings)
                .frame(width: 320, height: showSettings ? 420 : 280)
                .animation(.easeInOut(duration: 0.2), value: showSettings)
        } label: {
            if let nsImage = Bundle.module.image(forResource: "MenuBarIcon") {
                Image(nsImage: nsImage)
                    .renderingMode(.template)
            } else {
                Image(systemName: "note.text")
            }
        }
        .menuBarExtraStyle(.window)
    }
}

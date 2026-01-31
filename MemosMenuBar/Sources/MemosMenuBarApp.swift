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
            if let nsImage = loadMenuBarIcon() {
                Image(nsImage: nsImage)
                    .renderingMode(.template)
            } else {
                Image(systemName: "note.text")
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    private func loadMenuBarIcon() -> NSImage? {
        var image: NSImage?
        
        // Try loading from asset catalog via Bundle.module (works in Xcode)
        if let img = Bundle.module.image(forResource: "MenuBarIcon") {
            image = img
        }
        
        // For standalone .app builds: find the resource bundle inside the app
        if image == nil, let resourcesPath = Bundle.main.resourcePath {
            let bundlePath = (resourcesPath as NSString).appendingPathComponent("MemosMenuBar_MemosMenuBar.bundle")
            if let resourceBundle = Bundle(path: bundlePath) {
                // Try asset catalog in resource bundle
                if let img = resourceBundle.image(forResource: "MenuBarIcon") {
                    image = img
                }
                // Try PNG directly
                if image == nil,
                   let pngPath = resourceBundle.path(forResource: "MenuBarIcon", ofType: "png"),
                   let img = NSImage(contentsOfFile: pngPath) {
                    image = img
                }
            }
        }
        
        // Set standard menubar icon size (18x18 points)
        if let img = image {
            img.size = NSSize(width: 18, height: 18)
            img.isTemplate = true
            return img
        }
        
        return nil
    }
}

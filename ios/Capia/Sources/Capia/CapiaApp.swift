import SwiftUI

@main
struct CapiaApp: App {
    init() {
        CapiaFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

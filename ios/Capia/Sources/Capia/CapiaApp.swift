import SwiftUI

@main
struct CapiaApp: App {
    init() {
        CapiaFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                // O design só tem a aparência clara. Sem isto, no Modo Escuro os controles do
                // sistema (calendário, teclado, campos) desenham texto claro sobre o creme.
                .preferredColorScheme(.light)
        }
    }
}

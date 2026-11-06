import CapiaFlow
import Foundation
import SwiftUI

/// Raiz do app: abre nas boas-vindas ou, com espaço guardado, no mês provisório.
/// Grava o espaço no aparelho ao chegar à conclusão da configuração.
@MainActor
struct AppRootView: View {
    private static let store = SpaceStore(directory: URL.applicationSupportDirectory
        .appendingPathComponent("Capia", isDirectory: true))

    @State private var app = AppFlow(saved: AppRootView.store.load())
    @State private var saveFailed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch app.screen {
            case .getStarted(let screen):
                GetStartedView(screen: screen) { app.send($0) }
            case .setup:
                if let flow = app.setup {
                    SetupView(flow: flow, saveFailed: saveFailed,
                              edit: { app.editDraft($0) },
                              send: send,
                              retrySave: { save(app.currentSpace()) })
                    .transition(.opacity)
                }
            case .month:
                MonthPlaceholderView { app.returnFromMonth() }
                    .transition(.opacity)
            }
        }
        .background(CapiaTheme.cream)
        .foregroundStyle(CapiaTheme.ink)
        .font(CapiaFonts.body())
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: app.screen)
    }

    private func send(_ action: SetupAction) {
        if let space = app.send(action) { save(space) }
    }

    private func save(_ space: ConfiguredSpace?) {
        guard let space else { return }
        do {
            try Self.store.save(space)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}

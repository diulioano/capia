import CapiaFlow
import Foundation
import SwiftUI

/// Raiz do app: abre nas boas-vindas ou, com espaço guardado, no Início.
/// Grava o espaço no aparelho ao chegar à conclusão da configuração.
@MainActor
struct AppRootView: View {
    private static let store = SpaceStore(directory: URL.applicationSupportDirectory
        .appendingPathComponent("Capia", isDirectory: true))

    @State private var app = AppFlow(saved: AppRootView.store.load())
    @State private var saveFailed = false
    @State private var now = Date()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

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
            case .home:
                if let space = app.space {
                    let calendar = MonthCalendar(date: now, timeZone: .current)
                    HomeView(home: app.home,
                             record: app.record,
                             summary: MonthSummary(space: space, calendar: calendar),
                             space: space,
                             send: { app.send($0) },
                             addAnotherAccount: { app.addAnotherAccountFromHome() },
                             confirmSalary: { save(app.confirmSalary(in: calendar)) },
                             sendRecord: { app.send($0) },
                             saveRecord: saveRecord,
                             undoRecord: undoRecord)
                    .transition(.opacity)
                }
            }
        }
        .background(CapiaTheme.cream)
        .foregroundStyle(CapiaTheme.ink)
        .font(CapiaFonts.body())
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: app.screen)
        // Saudação e mês acompanham o relógio ao entrar no Início e ao voltar ao app.
        .onChange(of: app.screen) { now = Date() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { now = Date() }
        }
    }

    private func send(_ action: SetupAction) {
        if let space = app.send(action) { save(space) }
    }

    /// Grava o registro antes de confirmá-lo na sessão; se falhar, nada muda além do aviso.
    private func saveRecord() {
        guard let pending = app.pendingRecord(now: Date(), timeZone: .current) else { return }
        do {
            try Self.store.save(pending.space)
            app.commitRecord(pending.record)
            now = Date()
        } catch {
            app.recordSaveFailed()
        }
    }

    /// Grava o espaço sem o último registro e só então o remove da sessão.
    private func undoRecord() {
        guard let space = app.spaceUndoingLastRecord else { return }
        do {
            try Self.store.save(space)
            app.undoLastRecord()
        } catch {
            app.recordSaveFailed(.undo)
        }
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

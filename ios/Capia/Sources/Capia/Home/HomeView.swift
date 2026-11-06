import CapiaFlow
import SwiftUI

/// Início: resumo do mês, Contas e Metas, com botão de novo registro.
/// Esqueleto provisório da base; as telas finais chegam nas US.
@MainActor
struct HomeView: View {
    let home: HomeFlow
    let summary: MonthSummary
    let space: ConfiguredSpace
    let send: (HomeAction) -> Void
    let addAnotherAccount: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            switch home.tab {
            case .month:
                MonthView(summary: summary, home: home, send: send)
                Button("Adicionar registro") { send(.openNewRecord) }
            case .accounts:
                SpaceSummaryList(accounts: space.accounts, cards: space.cards)
                Button("Adicionar outra conta", action: addAnotherAccount)
            case .goals:
                Text("As metas de economia vêm numa próxima etapa do protótipo.")
            }
            HStack {
                Button("Início") { send(.select(.month)) }
                Button("Contas") { send(.select(.accounts)) }
                Button("Metas") { send(.select(.goals)) }
            }
        }
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CapiaTheme.cream.ignoresSafeArea())
        .sheet(isPresented: .init(get: { home.showingNewRecord },
                                  set: { if !$0 { send(.closeNewRecord) } })) {
            VStack(spacing: 16) {
                Text("O registro de receitas e gastos vem na próxima etapa do protótipo.")
                Button("Voltar ao início") { send(.closeNewRecord) }
            }
            .padding(24)
        }
    }
}

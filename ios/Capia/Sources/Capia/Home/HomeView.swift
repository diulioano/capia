import CapiaFlow
import SwiftUI

/// Início: resumo do mês, Contas e Metas, com a barra inferior e o botão de novo registro
/// do quadro "Resumo do mês".
@MainActor
struct HomeView: View {
    let home: HomeFlow
    /// Novo registro aberto sobre o Início.
    let record: RecordFlow?
    let summary: MonthSummary
    let space: ConfiguredSpace
    let send: (HomeAction) -> Void
    let addAnotherAccount: () -> Void
    let confirmSalary: () -> Void
    let sendRecord: (RecordAction) -> Void
    let saveRecord: () -> Void
    let undoRecord: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch home.tab {
            case .month:
                MonthView(summary: summary, home: home, send: send, confirmSalary: confirmSalary)
                    .overlay(alignment: .bottomTrailing) {
                        NewRecordButton { send(.openNewRecord) }
                            .padding(.trailing, 22)
                            .padding(.bottom, 20)
                    }
            case .accounts:
                AccountsTabView(space: space, valuesHidden: home.valuesHidden,
                                addAnotherAccount: addAnotherAccount)
            case .goals:
                PlaceholderTabView(title: "Metas",
                                   message: "As metas de economia vêm numa próxima etapa do protótipo.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CapiaTheme.cream.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) { TabBar(current: home.tab, send: send) }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: home.tab)
        // O Início fica por baixo, oculto para o VoiceOver enquanto o registro está aberto.
        .accessibilityHidden(record != nil)
        .overlay {
            if let record {
                NewRecordView(flow: record, send: sendRecord, save: saveRecord, undo: undoRecord,
                              close: { send(.closeNewRecord) })
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 14)))
            }
        }
        .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.34), value: record != nil)
    }
}

/// Botão + do quadro: 64 pt, raio 24, terracota; entra girando uma vez.
private struct NewRecordButton: View {
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        Button(action: action) {
            HomeIcon(kind: .plus).icon(size: 28, color: CapiaTheme.actionText, lineWidth: 2.6)
                .frame(width: 64, height: 64)
                .background(CapiaTheme.terracotta, in: RoundedRectangle(cornerRadius: 24))
                .shadow(color: CapiaTheme.terracotta.opacity(0.35), radius: 12, y: 10)
        }
        .buttonStyle(CapiaTapStyle())
        .scaleEffect(appeared || reduceMotion ? 1 : 0)
        .rotationEffect(.degrees(appeared || reduceMotion ? 0 : -90))
        .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: appeared)
        .accessibilityLabel("Adicionar registro")
        .onAppear { appeared = true }
    }
}

/// Barra inferior: Início, Contas e Metas; o item atual fica verde com ícone preenchido.
private struct TabBar: View {
    let current: HomeTab
    let send: (HomeAction) -> Void

    var body: some View {
        HStack(spacing: 0) {
            item(.month, "Início", .house)
            item(.accounts, "Contas", .card)
            item(.goals, "Metas", .bowl)
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        .background {
            CapiaTheme.tabBar.opacity(0.94)
                .overlay(alignment: .top) { Rectangle().fill(CapiaTheme.track).frame(height: 1) }
                .ignoresSafeArea(edges: .bottom)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Principal")
    }

    private func item(_ tab: HomeTab, _ label: String, _ icon: HomeIcon.Kind) -> some View {
        let selected = current == tab
        let color = selected ? CapiaTheme.notice : CapiaTheme.muted
        return Button { send(.select(tab)) } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selected {
                        HomeIcon(kind: icon == .bowl ? .bowlBody : icon)
                            .fill(CapiaTheme.selection)
                            .frame(width: 24, height: 24)
                    }
                    HomeIcon(kind: icon).icon(size: 24, color: color, lineWidth: 2)
                }
                .frame(width: 24, height: 24)
                Text(label)
                    .font(CapiaFonts.body(12, relativeTo: .caption2, weight: selected ? .bold : .semibold))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

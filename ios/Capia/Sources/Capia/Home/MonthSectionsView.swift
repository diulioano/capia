import CapiaFlow
import SwiftUI

/// Seções do quadro "Resumo do mês" sem registros: previstos, para onde foi e recentes.
/// Os textos de estado vazio são complementos ao design (contrato da funcionalidade 003).
@MainActor
struct MonthSectionsView: View {
    let categoryTab: CategoryTab
    let appeared: Bool
    let send: (HomeAction) -> Void

    var body: some View {
        VStack(spacing: 16) {
            forecast.modifier(HomeEnter(appeared: appeared, delay: 0.2))
            categories.modifier(HomeEnter(appeared: appeared, delay: 0.25))
            recent.modifier(HomeEnter(appeared: appeared, delay: 0.3))
        }
    }

    // MARK: Previstos

    private var forecast: some View {
        section(spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                title("Previstos para este mês")
                Spacer(minLength: 8)
                Text("nada a confirmar")
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .padding(.bottom, 6)
            emptyRow("Nada previsto por enquanto. Receitas e contas que se repetem aparecem aqui para você confirmar.",
                     minHeight: 60)
        }
    }

    // MARK: Para onde foi

    private var categories: some View {
        section(spacing: 14) {
            HStack(alignment: .center) {
                title("Para onde foi")
                Spacer(minLength: 8)
                tabs
            }
            RoundedRectangle(cornerRadius: 6)
                .fill(CapiaTheme.divider)
                .frame(height: 12)
                .accessibilityHidden(true)
            Text(categoryTab == .expenses ? "Nenhum gasto registrado neste mês."
                                          : "Nenhuma receita registrada neste mês.")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(categoryTab)
                .transition(.opacity)
        }
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            tab("Gastos", .expenses)
            tab("Receitas", .income)
        }
        .padding(3)
        .background(CapiaTheme.divider, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tipo")
    }

    private func tab(_ label: String, _ value: CategoryTab) -> some View {
        let selected = categoryTab == value
        return Button { send(.selectCategory(value)) } label: {
            Text(label)
                .font(CapiaFonts.body(13, relativeTo: .caption, weight: .bold))
                .foregroundStyle(CapiaTheme.ink)
                .padding(.horizontal, 12)
                .frame(minHeight: 38)
                .background(selected ? CapiaTheme.paper : .clear, in: RoundedRectangle(cornerRadius: 9))
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.2), value: selected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    // MARK: Registros recentes

    private var recent: some View {
        section(spacing: 0) {
            title("Registros recentes")
                .padding(.bottom, 6)
            emptyRow("Nenhum registro ainda. Use o botão + para registrar o primeiro.", minHeight: 58)
        }
    }

    // MARK: Componentes

    private func section<Content: View>(spacing: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: spacing, content: content)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 24))
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
            .foregroundStyle(CapiaTheme.ink)
            .accessibilityAddTraits(.isHeader)
    }

    /// Linha vazia com a divisória superior das linhas do quadro.
    private func emptyRow(_ text: String, minHeight: CGFloat) -> some View {
        Text(text)
            .font(CapiaFonts.body(14, relativeTo: .subheadline))
            .lineSpacing(2)
            .foregroundStyle(CapiaTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .overlay(alignment: .top) {
                Rectangle().fill(CapiaTheme.divider).frame(height: 1)
            }
    }
}

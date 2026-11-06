import CapiaFlow
import SwiftUI

/// Contas e cartões do espaço, distinguindo conta e cartão de crédito. Usada na conclusão
/// da configuração e na aba Contas do Início.
@MainActor
struct SpaceSummaryList: View {
    let accounts: [Account]
    let cards: [CreditCard]
    /// Substitui os saldos iniciais por `BRL.hidden` quando a pessoa oculta os valores.
    var valuesHidden = false

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                let balance = valuesHidden ? BRL.hidden : BRL.format(account.initialBalance)
                let spoken = valuesHidden ? "valor oculto" : BRL.format(account.initialBalance)
                row(title: account.name, detail: SetupCopy.kindDescription(account.kind)) {
                    Text(balance)
                        .font(CapiaFonts.body(16, weight: .bold))
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Conta \(account.name), \(SetupCopy.kindDescription(account.kind)), saldo inicial \(spoken)")
                divider(after: index, total: accounts.count + max(cards.count, 1))
            }
            if cards.isEmpty {
                Text("Sem cartão por enquanto.")
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
            } else {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    row(title: "Cartão \(card.name)",
                        detail: "Fecha dia \(card.closingDay) · vence dia \(card.dueDay)") {
                        Text("Separado")
                            .font(CapiaFonts.body(13, relativeTo: .caption, weight: .bold))
                            .foregroundStyle(CapiaTheme.notice)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(CapiaTheme.selection, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Cartão de crédito \(card.name), fecha dia \(card.closingDay), vence dia \(card.dueDay), separado da conta")
                    divider(after: accounts.count + index, total: accounts.count + cards.count)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 18)
        .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color(red: 80/255, green: 60/255, blue: 40/255).opacity(0.08), radius: 12, y: 8)
    }

    private func row<Trailing: View>(title: String, detail: String,
                                     @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CapiaFonts.body(16, weight: .bold))
                Text(detail)
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            trailing()
        }
        .foregroundStyle(CapiaTheme.ink)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func divider(after index: Int, total: Int) -> some View {
        if index < total - 1 {
            Rectangle().fill(Color(hex: 0xF4EBDC)).frame(height: 1)
        }
    }
}

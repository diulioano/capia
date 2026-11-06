import CapiaFlow
import SwiftUI

/// Etapa 4: "Quanto tem hoje em {conta}?". O valor é preenchido da direita para a
/// esquerda em centavos, como no design. O título fica no contêiner.
@MainActor
struct BalanceStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("Saldo inicial")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
                .padding(.top, 18)
                .accessibilityHidden(true)
            CentsField(value: draft.balance, accessibilityLabel: "Saldo inicial") { cents in
                edit { $0.balance = cents }
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            FlowingShortcuts(draft: draft, edit: edit)
                .padding(.top, 8)
            Text("Pode ser zero ou aproximado. Você ajusta quando quiser.")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .lineSpacing(4)
                .foregroundStyle(CapiaTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Atalhos `+ R$ 500`, `+ R$ 1.000` e `+ R$ 2.500`; quebram linha com texto ampliado.
@MainActor
private struct FlowingShortcuts: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { buttons }
            VStack(spacing: 8) { buttons }
        }
    }

    @ViewBuilder
    private var buttons: some View {
        ForEach(SetupDraft.balanceShortcutsInReais, id: \.self) { reais in
            Button { edit { $0.addToBalance(reais: reais) } } label: {
                Text(BRL.shortcutLabel(reais: reais))
                    .font(CapiaFonts.body(15, weight: .semibold))
                    .foregroundStyle(CapiaTheme.ink)
                    .fixedSize()
                    .padding(.horizontal, 16)
                    .frame(minHeight: 44)
                    .background(CapiaTheme.sand, in: Capsule())
            }
            .buttonStyle(CapiaTapStyle())
            .accessibilityLabel("Somar \(BRL.format(Cents(reais: reais)))")
        }
    }
}

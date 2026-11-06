import CapiaFlow
import SwiftUI

/// Etapa 5 (complemento ao design, funcionalidade 003): salário mensal, no mesmo campo
/// em centavos do saldo inicial. Vira uma receita prevista no Início; zero não cria nada.
@MainActor
struct SalaryStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 14) {
            Text("Salário mensal")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
                .padding(.top, 18)
                .accessibilityHidden(true)
            TextField("", text: Binding(get: { BRL.format(draft.salary) },
                                        set: { text in edit { $0.salary = Cents(typed: text) } }))
                .font(CapiaFonts.title(48))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .foregroundStyle(draft.salary == .zero ? CapiaTheme.placeholder : CapiaTheme.ink)
                .tint(CapiaTheme.caret)
                .keyboardType(.numberPad)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .focused($focused)
                .frame(minHeight: 72)
                .accessibilityLabel("Salário mensal")
                .accessibilityValue(BRL.format(draft.salary))
            Text("Ele aparece como previsto no seu mês até você confirmar que recebeu. Se sua renda varia, pode deixar zero.")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .lineSpacing(4)
                .foregroundStyle(CapiaTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .task {
            await Task.yield()
            focused = true
        }
    }
}

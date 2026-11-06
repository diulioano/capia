import CapiaFlow
import SwiftUI

/// Etapa 5 (complemento ao design, funcionalidade 003): salário mensal, no mesmo campo
/// em centavos do saldo inicial. Vira uma receita prevista no Início; zero não cria nada.
@MainActor
struct SalaryStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("Salário mensal")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
                .padding(.top, 18)
                .accessibilityHidden(true)
            CentsField(value: draft.salary, accessibilityLabel: "Salário mensal") { cents in
                edit { $0.salary = cents }
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            Text("Ele aparece como previsto no seu mês até você confirmar que recebeu. Se sua renda varia, pode deixar zero.")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .lineSpacing(4)
                .foregroundStyle(CapiaTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

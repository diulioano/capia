import SwiftUI

/// Destino provisório de "Ver meu mês" e abertura do app com espaço guardado.
/// O resumo do mês é uma funcionalidade posterior.
@MainActor
struct MonthPlaceholderView: View {
    let backToSummary: () -> Void
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        ScrollView {
            Text("O resumo do seu mês vem na próxima etapa do protótipo.")
                .font(CapiaFonts.title(27))
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Voltar ao resumo", action: backToSummary)
                .buttonStyle(CapiaPrimaryButtonStyle())
                .padding(24)
                .background(CapiaTheme.cream)
        }
        .background(CapiaTheme.cream.ignoresSafeArea())
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }
}

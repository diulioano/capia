import SwiftUI

/// Destino provisório de uma aba ainda não construída, no sistema visual do Início.
@MainActor
struct PlaceholderTabView: View {
    let title: String
    let message: String

    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(CapiaFonts.title(30))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($titleFocused)
                Text(message)
                    .font(CapiaFonts.body(16))
                    .lineSpacing(4)
                    .foregroundStyle(CapiaTheme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 22)
        }
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }
}

/// Destino provisório do botão +, aberto sobre o Início.
@MainActor
struct NewRecordPlaceholderView: View {
    let close: () -> Void

    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        ScrollView {
            Text("O registro de receitas e gastos vem na próxima etapa do protótipo.")
                .font(CapiaFonts.title(27))
                .lineSpacing(4)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Voltar ao início", action: close)
                .buttonStyle(CapiaPrimaryButtonStyle())
                .padding(24)
        }
        .foregroundStyle(CapiaTheme.ink)
        .background(CapiaTheme.cream.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }
}

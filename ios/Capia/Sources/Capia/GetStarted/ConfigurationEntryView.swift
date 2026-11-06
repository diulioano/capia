import SwiftUI

@MainActor
struct ConfigurationEntryView: View {
    let back: () -> Void
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        ScrollView {
            Text("A configuração do seu espaço vem na próxima etapa do protótipo.")
                .font(CapiaFonts.title(27))
                .foregroundStyle(CapiaTheme.ink)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
        }
        .clipped()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Voltar à apresentação", action: back)
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

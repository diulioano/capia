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

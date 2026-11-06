import CapiaFlow
import SwiftUI

/// Aba Contas provisória: contas e cartões do espaço, como na conclusão da configuração,
/// e "Adicionar outra conta". O quadro "Contas e cartões" chega numa funcionalidade própria.
@MainActor
struct AccountsTabView: View {
    let space: ConfiguredSpace
    let valuesHidden: Bool
    let addAnotherAccount: () -> Void

    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Contas e cartões")
                    .font(CapiaFonts.title(30))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($titleFocused)
                    .padding(.horizontal, 4)
                    .padding(.top, 22)
                SpaceSummaryList(accounts: space.accounts, cards: space.cards, valuesHidden: valuesHidden)
                Text("A gestão completa de contas e cartões vem numa próxima etapa do protótipo.")
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                Button(action: addAnotherAccount) {
                    Text("Adicionar outra conta")
                        .font(CapiaFonts.body(15, weight: .semibold))
                        .foregroundStyle(CapiaTheme.action)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(CapiaTapStyle())
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }
}

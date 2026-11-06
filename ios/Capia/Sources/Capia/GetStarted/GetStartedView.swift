import CapiaFlow
import SwiftUI

@MainActor
struct GetStartedView: View {
    @State private var flow = GetStartedFlow()
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        // Capture the rendered origin, rather than reading the latest state in a tap.
        let source = flow.screen
        Group {
            if source == .welcome {
                WelcomeView { flow.send(.init(.start, from: source)) }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Capia · esqueleto de navegação")
                            .font(.caption)
                        switch source {
                        case .welcome:
                            EmptyView()
                        case .introduction(let step):
                            Text(title(for: step)).font(CapiaFonts.title(27))
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityFocused($titleFocused)
                            Text("Etapa \(step.position) de 3")
                            Text("Apresentação provisória para validar a navegação.")
                            action("Voltar", .back, from: source)
                            action("Pular", .skip, from: source)
                            if step == .goals {
                                action("Configurar meu espaço", .configure, from: source)
                            } else {
                                action("Continuar", .continueIntroduction, from: source)
                            }
                        case .configurationEntry:
                            Text("A configuração do seu espaço vem na próxima etapa do protótipo.")
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityFocused($titleFocused)
                            action("Voltar à apresentação", .returnToIntroduction, from: source)
                        }
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(CapiaTheme.cream)
        .foregroundStyle(CapiaTheme.ink)
        .font(CapiaFonts.body())
        .onChange(of: flow.screen) { titleFocused = true }
    }

    private func action(_ title: String, _ intent: GetStartedAction.Intent,
                        from source: GetStartedScreen) -> some View {
        Button(title) { flow.send(GetStartedAction(intent, from: source)) }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: 44)
    }

    private func title(for step: IntroStep) -> String {
        switch step {
        case .register: "Registre do seu jeito"
        case .monthlyOverview: "Entenda para onde vai"
        case .goals: "Metas sem aperto"
        }
    }
}

import CapiaFlow
import SwiftUI

@MainActor
struct GetStartedView: View {
    @State private var flow = GetStartedFlow()

    var body: some View {
        // Capture the rendered origin, rather than reading the latest state in a tap.
        let source = flow.screen
        ScrollView {
            VStack(spacing: 24) {
                Text("Capia · esqueleto de navegação")
                    .font(.caption)
                switch source {
                case .welcome:
                    Text("Boas-vindas ao seu refúgio").font(.largeTitle)
                    action("Começar", .start, from: source)
                case .introduction(let step):
                    Text(title(for: step)).font(.largeTitle)
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
                    action("Voltar à apresentação", .returnToIntroduction, from: source)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity)
        }
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

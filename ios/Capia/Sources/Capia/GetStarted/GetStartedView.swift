import CapiaFlow
import SwiftUI

/// Boas-vindas e apresentação. O estado pertence à raiz (`AppRootView`).
@MainActor
struct GetStartedView: View {
    let screen: GetStartedScreen
    let send: (GetStartedAction) -> Void

    var body: some View {
        // Capture the rendered origin, rather than reading the latest state in a tap.
        let source = screen
        switch source {
        case .welcome:
            WelcomeView { send(.init(.start, from: source)) }
                .transition(.opacity)
        case .introduction(let step):
            IntroductionView(step: step) { intent in
                send(.init(intent, from: source))
            }
            .id(step.position)
            .transition(.opacity)
        case .setup:
            // A raiz exibe a configuração; este caso não é renderizado aqui.
            EmptyView()
        }
    }
}

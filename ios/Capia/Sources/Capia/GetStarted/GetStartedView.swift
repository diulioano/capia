import CapiaFlow
import SwiftUI

@MainActor
struct GetStartedView: View {
    @State private var flow = GetStartedFlow()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Capture the rendered origin, rather than reading the latest state in a tap.
        let source = flow.screen
        Group {
            switch source {
            case .welcome:
                WelcomeView { flow.send(.init(.start, from: source)) }
                    .transition(.opacity)
            case .introduction(let step):
                IntroductionView(step: step) { intent in
                    flow.send(.init(intent, from: source))
                }
                .id(step.position)
                .transition(.opacity)
            case .configurationEntry(let origin):
                ConfigurationEntryView {
                    flow.send(.init(.returnToIntroduction, from: source))
                }
                .id(origin.position)
                .transition(.opacity)
            }
        }
        .background(CapiaTheme.cream)
        .foregroundStyle(CapiaTheme.ink)
        .font(CapiaFonts.body())
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: flow.screen)
    }
}

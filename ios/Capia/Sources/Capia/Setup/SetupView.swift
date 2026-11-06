import CapiaFlow
import SwiftUI

/// Configuração inicial, conforme o quadro "Configuração inicial": etapas com Voltar,
/// progresso, capivara com dica, título e Continuar fixo; conclusão em tela própria.
@MainActor
struct SetupView: View {
    let flow: SetupFlow
    let saveFailed: Bool
    let edit: ((inout SetupDraft) -> Void) -> Void
    let send: (SetupAction) -> Void
    let retrySave: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        if flow.step == .done {
            // Capture the rendered step, rather than reading the latest state in a tap.
            let source = flow.step
            SetupDoneView(flow: flow, saveFailed: saveFailed,
                          send: { send(.init($0, from: source)) }, retrySave: retrySave)
                .transition(.opacity)
        } else {
            steps
        }
    }

    @ViewBuilder
    private var steps: some View {
        // Capture the rendered step, rather than reading the latest state in a tap.
        let source = flow.step
        VStack(alignment: .leading, spacing: 0) {
            header(source)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    mascot(source)
                        .padding(.top, 18)
                    stepBody(source)
                        .id(source)
                        .transition(stepTransition)
                        .padding(.top, 22)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if source != .done {
                Button("Continuar") { send(.init(.continueStep, from: source)) }
                    .buttonStyle(CapiaContinueButtonStyle())
                    .disabled(!flow.canContinue)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(CapiaTheme.cream)
            }
        }
        .background(CapiaTheme.cream.ignoresSafeArea())
        .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4), value: source)
        .task(id: source) {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }

    private var stepTransition: AnyTransition {
        reduceMotion ? .identity : .asymmetric(insertion: .opacity.combined(with: .offset(x: 24)),
                                               removal: .identity)
    }

    // MARK: Cabeçalho

    @ViewBuilder
    private func header(_ source: SetupStep) -> some View {
        HStack(spacing: 14) {
            if flow.canGoBack {
                Button { send(.init(.back, from: source)) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(CapiaTheme.ink)
                        .frame(width: 44, height: 44)
                        .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(CapiaTapStyle())
                .accessibilityLabel("Voltar")
            }
            if let position = source.position {
                ProgressTrack(position: position, total: SetupStep.count, reduceMotion: reduceMotion)
            }
        }
        .frame(minHeight: 44)
    }

    // MARK: Capivara e dica

    @ViewBuilder
    private func mascot(_ source: SetupStep) -> some View {
        if source != .done {
            HStack(alignment: .bottom, spacing: 6) {
                Image(uiImage: SetupCopy.image(for: flow.mood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .accessibilityHidden(true)
                Text(SetupCopy.tip(for: source))
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .lineSpacing(3)
                    .foregroundStyle(CapiaTheme.tipText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 13)
                    .background(CapiaTheme.paper, in: UnevenRoundedRectangle(
                        topLeadingRadius: 16, bottomLeadingRadius: 4,
                        bottomTrailingRadius: 16, topTrailingRadius: 16))
                    .shadow(color: Color(red: 80/255, green: 60/255, blue: 40/255).opacity(0.10), radius: 7, y: 4)
                    .padding(.bottom, 26)
                    .id(source)
                    .transition(reduceMotion ? .identity : .opacity)
            }
        }
    }

    // MARK: Etapas

    @ViewBuilder
    private func stepBody(_ source: SetupStep) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(SetupCopy.title(for: source, draft: flow.draft))
                .font(CapiaFonts.title(source == .cardDates ? 26 : 28))
                .lineSpacing(4)
                .foregroundStyle(CapiaTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)
                .padding(.bottom, source == .goals ? 4 : 0)
            switch source {
            case .name:
                NameStepView(draft: flow.draft, edit: edit,
                             submit: { send(.init(.continueStep, from: source)) })
            case .goals:
                GoalsStepView(draft: flow.draft, edit: edit)
            case .account:
                AccountStepView(draft: flow.draft, edit: edit,
                                submit: { send(.init(.continueStep, from: source)) })
            case .balance:
                BalanceStepView(draft: flow.draft, edit: edit)
            case .salary:
                SalaryStepView(draft: flow.draft, edit: edit)
            case .cardQuestion:
                CardQuestionStepView(draft: flow.draft, edit: edit)
            case .cardDates:
                CardDatesStepView(draft: flow.draft, edit: edit)
            case .done:
                EmptyView()
            }
        }
    }
}

/// Barra de progresso de 6 pt, preenchida até a etapa atual.
private struct ProgressTrack: View {
    let position: Int
    let total: Int
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(CapiaTheme.track)
                Capsule().fill(CapiaTheme.action)
                    .frame(width: geometry.size.width * CGFloat(position) / CGFloat(total))
            }
        }
        .frame(height: 6)
        .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.5), value: position)
        .accessibilityElement()
        .accessibilityLabel("Progresso da configuração")
        .accessibilityValue("Etapa \(position) de \(total)")
    }
}

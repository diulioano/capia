import CapiaFlow
import SwiftUI

@MainActor
struct IntroductionView: View {
    let step: IntroStep
    let send: (GetStartedAction.Intent) -> Void
    @Environment(\.dynamicTypeSize) private var textSize
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 14) {
                HStack(alignment: .top) {
                    Button { send(.back) } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityLabel("Voltar")
                    Spacer(minLength: 16)
                    Button("Pular") { send(.skip) }
                        .font(CapiaFonts.body(15, weight: .semibold))
                        .foregroundStyle(CapiaTheme.action)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .padding(.horizontal, 20)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        artwork
                        Text(title)
                            .font(CapiaFonts.title(27))
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityFocused($titleFocused)
                            .padding(.top, 8)
                            .padding(.horizontal, 6)
                        Text(description)
                            .font(CapiaFonts.body())
                            .lineSpacing(5)
                            .foregroundStyle(CapiaTheme.secondary)
                            .padding(.horizontal, 6)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                .clipped()
                footer.padding(.horizontal, 20)
            }
            .padding(.top, max(0, 58 - geometry.safeAreaInsets.top))
            .padding(.bottom, max(4, 38 - geometry.safeAreaInsets.bottom))
        }
        .foregroundStyle(CapiaTheme.ink)
        .tint(CapiaTheme.action)
        .background(CapiaTheme.cream.ignoresSafeArea())
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }

    @ViewBuilder private var artwork: some View {
        switch step {
        case .register: RegistrationArtwork()
        case .monthlyOverview: MonthlyOverviewArtwork()
        case .goals: GoalsArtwork()
        }
    }

    @ViewBuilder private var footer: some View {
        if textSize.isAccessibilitySize {
            verticalFooter
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) {
                    progress
                    Spacer(minLength: 0)
                    continueButton.fixedSize(horizontal: true, vertical: false)
                }
                verticalFooter
            }
        }
    }

    private var verticalFooter: some View {
        VStack(alignment: .leading, spacing: 16) {
            progress
            continueButton
        }
    }

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(1...3, id: \.self) { position in
                Capsule()
                    .fill(position == step.position ? CapiaTheme.action : Color(red: 207/255, green: 196/255, blue: 179/255))
                    .frame(width: position == step.position ? 24 : 8, height: 8)
            }
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Etapa \(step.position) de 3")
    }

    private var continueButton: some View {
        Button(step == .goals ? "Configurar meu espaço" : "Continuar") {
            send(step == .goals ? .configure : .continueIntroduction)
        }
        .buttonStyle(CapiaPrimaryButtonStyle())
    }

    private var title: String {
        switch step {
        case .register: "Registre do seu jeito"
        case .monthlyOverview: "Entenda para onde vai"
        case .goals: "Metas sem aperto"
        }
    }

    private var description: String {
        switch step {
        case .register: "Digite, fale ou mande a foto de um recibo. A gente prepara um rascunho e você só confere."
        case .monthlyOverview: "Receitas, gastos e faturas do mês num só lugar. Contas fixas aparecem como previsão até você confirmar."
        case .goals: "Diga quanto quer juntar e a gente sugere quanto reservar por mês, olhando o que entra e o que sai."
        }
    }
}

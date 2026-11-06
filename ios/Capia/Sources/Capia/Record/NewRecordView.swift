import CapiaFlow
import SwiftUI

/// Novo registro do quadro "Novo registro", aberto sobre o Início: fechar, título, abas
/// Digitar, Falar e Foto, a fase atual e o aviso de registro salvo ou de falha.
@MainActor
struct NewRecordView: View {
    let flow: RecordFlow
    let send: (RecordAction) -> Void
    let save: () -> Void
    let undo: () -> Void
    let close: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @AccessibilityFocusState private var titleFocused: Bool

    /// Duração do aviso: 3 s, mais curta que os 4,2 s do quadro, a pedido do usuário.
    private static let toastDuration: Duration = .seconds(3)

    var body: some View {
        VStack(spacing: 0) {
            header
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .foregroundStyle(CapiaTheme.ink)
        .background(CapiaTheme.cream.ignoresSafeArea())
        .overlay(alignment: .bottom) { toast }
        .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.34), value: flow.phase)
        .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.34), value: flow.mode)
        .task(id: toastTimer) {
            // O aviso some em 3 s. Com VoiceOver, fica até a próxima ação, para dar tempo de
            // alcançar "Desfazer"; com falha, o registro guardado espera "Tentar de novo".
            guard flow.toast != nil, flow.failure == nil, !voiceOver else { return }
            try? await Task.sleep(for: Self.toastDuration)
            guard !Task.isCancelled else { return }
            send(.dismissToast)
        }
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }

    private var toastTimer: String {
        "\(flow.toast?.record.id.uuidString ?? "-")|\(String(describing: flow.failure))|\(voiceOver)"
    }

    /// Ações das fases. Com VoiceOver, a próxima ação fecha o aviso de registro salvo.
    private func forward(_ action: RecordAction) {
        if voiceOver, flow.toast != nil, action != .dismissToast { send(.dismissToast) }
        send(action)
    }

    // MARK: Cabeçalho

    private var header: some View {
        VStack(spacing: 14) {
            HStack {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(CapiaTheme.ink)
                        .frame(width: 44, height: 44)
                        .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(CapiaTapStyle())
                .accessibilityLabel(RecordCopy.closeLabel)
                Spacer(minLength: 8)
                Text(RecordCopy.title(flow))
                    .font(CapiaFonts.title(20))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($titleFocused)
                Spacer(minLength: 8)
                Color.clear.frame(width: 44, height: 44)
            }
            modeTabs
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(CapiaTheme.cream)
    }

    private var modeTabs: some View {
        HStack(spacing: 4) {
            ForEach(RecordMode.allCases, id: \.self) { mode in
                let selected = flow.mode == mode
                Button { forward(.selectMode(mode)) } label: {
                    HStack(spacing: 6) {
                        RecordModeIcon(mode: mode)
                            .stroke(CapiaTheme.ink, style: StrokeStyle(lineWidth: 1.8 * 18 / 24, lineCap: .round,
                                                                        lineJoin: .round))
                            .frame(width: 18, height: 18)
                            .accessibilityHidden(true)
                        Text(RecordCopy.modeLabel(mode))
                            .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(selected ? CapiaTheme.paper : .clear, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: selected ? CapiaTheme.shadow.opacity(0.10) : .clear, radius: 4, y: 2)
                    .contentShape(Rectangle())
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: selected)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
        .padding(4)
        .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Forma de registro")
    }

    // MARK: Conteúdo

    @ViewBuilder
    private var content: some View {
        switch (flow.mode, flow.phase) {
        case (.type, .amount):
            AmountPadView(flow: flow, send: forward)
                .transition(enter)
        case (.type, .details):
            RecordFormView(flow: flow, send: forward, save: save)
                .transition(enter)
        case (.speak, _), (.photo, _):
            RecordModePlaceholderView(mode: flow.mode, send: forward)
                .transition(enter)
        }
    }

    /// `.enter` do quadro: sobe 14 pt e aparece.
    private var enter: AnyTransition {
        reduceMotion ? .identity : .asymmetric(insertion: .opacity.combined(with: .offset(y: 14)), removal: .opacity)
    }

    // MARK: Aviso

    private var toast: some View {
        ZStack {
            if let failure = flow.failure {
                // Mesmo lugar e estilo, com a capivara pensativa no lugar da comemorando.
                RecordToastView(image: CapiaImages.thinkingCapybara, title: RecordCopy.saveFailed, subtitle: nil,
                                actionTitle: RecordCopy.retry) {
                    switch failure {
                    case .save: save()
                    case .undo: undo()
                    }
                }
                .id("failure-\(String(describing: failure))")
                .transition(toastTransition)
            } else if let saved = flow.toast {
                RecordToastView(image: CapiaImages.celebratingCapybara, title: RecordCopy.saved,
                                subtitle: RecordCopy.toastSubtitle(saved.record, accounts: flow.accounts,
                                                                   cards: flow.cards),
                                actionTitle: RecordCopy.undo, action: undo)
                .id(saved.record.id)
                .transition(toastTransition)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, flow.phase == .details ? 104 : 24)
        // Entra subindo e sai descendo, com a curva do quadro; com Reduzir Movimento, só esmaece.
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4),
                   value: toastIdentity)
    }

    /// Muda quando o aviso aparece, troca ou some, para animar a entrada e a saída.
    private var toastIdentity: String {
        if let failure = flow.failure { return "failure-\(String(describing: failure))" }
        return flow.toast?.record.id.uuidString ?? "none"
    }

    private var toastTransition: AnyTransition {
        reduceMotion ? .opacity : .offset(y: 160).combined(with: .opacity)
    }
}

/// Ícones das abas, desenhados na grade 24 × 24 dos SVGs do quadro.
private struct RecordModeIcon: Shape {
    let mode: RecordMode

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 24
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: rect.minX + x * s, y: rect.minY + y * s) }
        var path = Path()
        switch mode {
        case .type:
            // Teclado: `M2 6h20v13H2zM6 10h.01M10 10h.01M14 10h.01M18 10h.01M7 15h10`
            path.addRoundedRect(in: CGRect(origin: p(2, 6), size: CGSize(width: 20 * s, height: 13 * s)),
                                cornerSize: CGSize(width: 2 * s, height: 2 * s))
            for x in [CGFloat(6), 10, 14, 18] {
                path.move(to: p(x, 10)); path.addLine(to: p(x + 0.01, 10))
            }
            path.move(to: p(7, 15)); path.addLine(to: p(17, 15))
        case .speak:
            // Microfone: `M9 3h6v11H9zM5 11a7 7 0 0 0 14 0M12 18v3`
            path.addRoundedRect(in: CGRect(origin: p(9, 3), size: CGSize(width: 6 * s, height: 11 * s)),
                                cornerSize: CGSize(width: 3 * s, height: 3 * s))
            path.move(to: p(5, 11))
            path.addArc(center: p(12, 11), radius: 7 * s, startAngle: .degrees(180), endAngle: .degrees(0),
                        clockwise: true)
            path.move(to: p(12, 18)); path.addLine(to: p(12, 21))
        case .photo:
            // Câmera: `M4 8h3l2-3h6l2 3h3v11H4zM12 10a3 3 0 1 0 0 6a3 3 0 1 0 0-6`
            path.move(to: p(4, 8)); path.addLine(to: p(7, 8)); path.addLine(to: p(9, 5))
            path.addLine(to: p(15, 5)); path.addLine(to: p(17, 8)); path.addLine(to: p(20, 8))
            path.addLine(to: p(20, 19)); path.addLine(to: p(4, 19)); path.closeSubpath()
            path.addEllipse(in: CGRect(origin: p(9, 10), size: CGSize(width: 6 * s, height: 6 * s)))
        }
        return path
    }
}

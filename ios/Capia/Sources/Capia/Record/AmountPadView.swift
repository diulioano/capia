import CapiaFlow
import SwiftUI

/// Fase do valor do quadro: Gasto ou Receita, valor com cursor, teclado e Continuar.
@MainActor
struct AmountPadView: View {
    let flow: RecordFlow
    let send: (RecordAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var caretVisible = true

    private let keys: [(label: String, spoken: String, key: PadKey)] =
        (1...9).map { ("\($0)", "\($0)", PadKey.digit($0)) }
        + [("00", "Dois zeros", .doubleZero), ("0", "0", .digit(0)), ("⌫", "Apagar", .delete)]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    kindSelector
                    Spacer(minLength: 24)
                    amount
                    Spacer(minLength: 24)
                    keypad
                    Button("Continuar") { send(.continueToDetails) }
                        .buttonStyle(CapiaContinueButtonStyle())
                        .disabled(!flow.canContinue)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 30)
                .frame(minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    // MARK: Tipo

    private var kindSelector: some View {
        HStack(spacing: 8) {
            kindChip(.expense, selectedFill: CapiaTheme.expenseChip, selectedBorder: CapiaTheme.terracotta)
            kindChip(.income, selectedFill: CapiaTheme.selection, selectedBorder: CapiaTheme.action)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tipo de registro")
    }

    private func kindChip(_ kind: RecordKind, selectedFill: Color, selectedBorder: Color) -> some View {
        let selected = flow.draft.kind == kind
        return Button { send(.selectKind(kind)) } label: {
            Text(RecordCopy.kindLabel(kind))
                .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .bold))
                .foregroundStyle(CapiaTheme.ink)
                .padding(.horizontal, 18)
                .frame(minHeight: 38)
                .background(selected ? selectedFill : CapiaTheme.paper, in: Capsule())
                .overlay(Capsule().strokeBorder(selected ? selectedBorder : CapiaTheme.border, lineWidth: 2))
                .padding(.vertical, 3)
                .contentShape(Rectangle())
                .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: selected)
        }
        .buttonStyle(CapiaTapStyle())
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    // MARK: Valor

    private var amount: some View {
        VStack(spacing: 6) {
            Text(RecordCopy.padHint(flow.draft.kind))
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
            HStack(spacing: 4) {
                Text(BRL.format(flow.draft.amount))
                    .font(CapiaFonts.title(50))
                    .monospacedDigit()
                    .foregroundStyle(flow.draft.amount == .zero ? CapiaTheme.placeholder : CapiaTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .modifier(AmountBounce(trigger: flow.draft.amount))
                RoundedRectangle(cornerRadius: 2)
                    .fill(CapiaTheme.caret)
                    .frame(width: 3, height: 46)
                    .opacity(caretVisible ? 1 : 0)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(RecordCopy.padHint(flow.draft.kind))
        .accessibilityValue(BRL.format(flow.draft.amount))
        .task(id: reduceMotion) {
            // Cursor do quadro: 1 s em passos, metade visível. Fixo com redução de movimento.
            caretVisible = true
            guard !reduceMotion else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                caretVisible.toggle()
            }
        }
    }

    // MARK: Teclado

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(keys, id: \.label) { entry in
                Button {
                    send(.press(entry.key))
                    announceAmount(after: entry.key)
                } label: {
                    Text(entry.label)
                        .font(CapiaFonts.title(24))
                        .foregroundStyle(CapiaTheme.ink)
                        .frame(maxWidth: .infinity, minHeight: 58)
                }
                .buttonStyle(PadKeyStyle())
                .accessibilityLabel(entry.spoken)
            }
        }
    }

    /// Anuncia o valor depois da tecla, como o `aria-live` do quadro.
    private func announceAmount(after key: PadKey) {
        var next = flow
        next.send(.press(key))
        AccessibilityNotification.Announcement(BRL.format(next.draft.amount)).post()
    }
}

/// Tecla do quadro: creme; ao tocar, areia e escala 0,94.
private struct PadKeyStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? CapiaTheme.keyPressed : CapiaTheme.paper,
                        in: RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// `.amt` do quadro: o valor salta de 106% a cada mudança, em 0,22 s.
private struct AmountBounce: ViewModifier {
    let trigger: Cents
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.keyframeAnimator(initialValue: 1.0, trigger: trigger) { view, scale in
                view.scaleEffect(scale)
            } keyframes: { _ in
                MoveKeyframe(1.06)
                SpringKeyframe(1.0, duration: 0.22, spring: .bouncy)
            }
        }
    }
}

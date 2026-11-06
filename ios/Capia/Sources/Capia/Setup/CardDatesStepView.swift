import CapiaFlow
import SwiftUI

/// Etapa 6: "Datas do cartão {conta}". Fileiras de dias de 1 a 31 para fechamento e
/// vencimento, com aviso do design ou erro quando os dias coincidem.
@MainActor
struct CardDatesStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shakes = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Fecha no dia").padding(.top, 6)
            DayRow(selected: draft.closingDay, title: "Fecha no dia") { day in edit { $0.setClosingDay(day) } }
            sectionTitle("Vence no dia").padding(.top, 8)
            DayRow(selected: draft.dueDay, title: "Vence no dia") { day in edit { $0.setDueDay(day) } }
            Group {
                if draft.areCardDaysValid {
                    message("Compras a partir do dia \(draft.closingDay) entram na fatura seguinte. Parcelas são distribuídas automaticamente pelos próximos meses.",
                            background: CapiaTheme.selection, foreground: CapiaTheme.notice)
                } else {
                    message("Fechamento e vencimento precisam ser em dias diferentes.",
                            background: CapiaTheme.errorBackground, foreground: CapiaTheme.errorText)
                        .modifier(Shake(amount: CGFloat(shakes)))
                        .onAppear {
                            AccessibilityNotification.Announcement("Fechamento e vencimento precisam ser em dias diferentes.").post()
                            guard !reduceMotion else { return }
                            withAnimation(.easeInOut(duration: 0.35)) { shakes += 1 }
                        }
                }
            }
            .padding(.top, 6)
            .transition(.opacity)
        }
        .animation(.easeOut(duration: 0.3), value: draft.areCardDaysValid)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(CapiaFonts.body(15, relativeTo: .headline, weight: .bold))
            .foregroundStyle(CapiaTheme.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private func message(_ text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(CapiaFonts.body(14, relativeTo: .subheadline))
            .lineSpacing(4)
            .foregroundStyle(foreground)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(background, in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Fileira horizontal de dias, de borda a borda, que abre rolada até o dia escolhido.
@MainActor
private struct DayRow: View {
    let selected: Int
    let title: String
    let pick: (Int) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(Array(CreditCard.days), id: \.self) { day in
                        dayButton(day)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 2)
                .padding(.bottom, 6)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -20)
            .onAppear { proxy.scrollTo(selected, anchor: .center) }
        }
    }

    private func dayButton(_ day: Int) -> some View {
        let on = day == selected
        return Button { pick(day) } label: {
            Text("\(day)")
                .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(on ? CapiaTheme.actionText : CapiaTheme.ink)
                .frame(minWidth: 48, minHeight: 52)
                .background(on ? CapiaTheme.action : CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 16))
                .animation(.easeOut(duration: 0.2), value: on)
        }
        .buttonStyle(CapiaTapStyle())
        .id(day)
        .accessibilityLabel("\(title) \(day)")
        .accessibilityAddTraits(on ? [.isButton, .isSelected] : .isButton)
    }
}

/// Tremor do design: −4 pt a 25% e +4 pt a 75% do movimento.
private struct Shake: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: -4 * sin(amount * 2 * .pi), y: 0))
    }
}

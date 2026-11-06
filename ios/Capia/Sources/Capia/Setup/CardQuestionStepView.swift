import CapiaFlow
import SwiftUI

/// Etapa 5: "Você usa cartão de crédito de {conta}?". O título fica no contêiner.
@MainActor
struct CardQuestionStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            option(answer: true, title: "Sim, tenho cartão",
                   detail: "Acompanho a fatura separada da conta") {
                CardIcon().stroke(CapiaTheme.action, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
            option(answer: false, title: "Agora não", detail: "Dá para adicionar depois") {
                NotNowIcon().stroke(CapiaTheme.muted, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
        }
    }

    private func option<Icon: View>(answer: Bool, title: String, detail: String,
                                    @ViewBuilder icon: () -> Icon) -> some View {
        let selected = draft.hasCard == answer
        return Button { edit { $0.hasCard = answer } } label: {
            HStack(spacing: 14) {
                icon()
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
                        .foregroundStyle(CapiaTheme.ink)
                    Text(detail)
                        .font(CapiaFonts.body(14, relativeTo: .subheadline))
                        .foregroundStyle(CapiaTheme.muted)
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .frame(minHeight: 76)
            .contentShape(Rectangle())
            .capiaOption(selected: selected, cornerRadius: 20)
        }
        .buttonStyle(CapiaTapStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(detail)")
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

/// `rect x2 y5 w20 h14 rx3` e `M2 10h20 M6 15h4`, em uma caixa 24 × 24.
private struct CardIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 24
        var path = Path(roundedRect: CGRect(x: 2 * s, y: 5 * s, width: 20 * s, height: 14 * s),
                        cornerRadius: 3 * s)
        path.move(to: CGPoint(x: 2 * s, y: 10 * s))
        path.addLine(to: CGPoint(x: 22 * s, y: 10 * s))
        path.move(to: CGPoint(x: 6 * s, y: 15 * s))
        path.addLine(to: CGPoint(x: 10 * s, y: 15 * s))
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

/// `circle r9` e `M8 12h8`, em uma caixa 24 × 24.
private struct NotNowIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 24
        var path = Path(ellipseIn: CGRect(x: 3 * s, y: 3 * s, width: 18 * s, height: 18 * s))
        path.move(to: CGPoint(x: 8 * s, y: 12 * s))
        path.addLine(to: CGPoint(x: 16 * s, y: 12 * s))
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

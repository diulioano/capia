import CapiaFlow
import SwiftUI

/// Etapa 3: "Vamos cadastrar sua primeira conta". O título fica no contêiner.
@MainActor
struct AccountStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void
    let submit: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ForEach(AccountKind.allCases, id: \.self) { kind in
                    kindOption(kind, selected: draft.accountKind == kind)
                }
            }
            Text(SetupCopy.accountFieldLabel(draft.accountKind))
                .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .semibold))
                .foregroundStyle(CapiaTheme.secondary)
                .padding(.top, 6)
                .accessibilityHidden(true)
            TextField("", text: Binding(get: { draft.accountName },
                                        set: { value in edit { $0.accountName = value } }),
                      prompt: Text("Ex.: Banco Aurora").foregroundStyle(CapiaTheme.placeholder))
                .font(CapiaFonts.title(26))
                .foregroundStyle(CapiaTheme.ink)
                .tint(CapiaTheme.caret)
                .textContentType(.organizationName)
                .autocorrectionDisabled()
                .submitLabel(.continue)
                .focused($focused)
                .onSubmit { if draft.isAccountValid { submit() } }
                .accessibilityLabel(SetupCopy.accountFieldLabel(draft.accountKind))
                .frame(minHeight: 56)
                .capiaUnderline(focused: focused)
            Text("Você pode adicionar outras contas depois.")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
        }
        .task {
            await Task.yield()
            focused = true
        }
    }

    private func kindOption(_ kind: AccountKind, selected: Bool) -> some View {
        Button { edit { $0.accountKind = kind } } label: {
            VStack(spacing: 8) {
                AccountKindIcon(kind: kind)
                    .stroke(selected ? CapiaTheme.action : CapiaTheme.muted,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 26, height: 26)
                    .accessibilityHidden(true)
                Text(SetupCopy.kindLabel(kind))
                    .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .semibold))
                    .foregroundStyle(CapiaTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, minHeight: 96)
            .contentShape(Rectangle())
            .capiaOption(selected: selected, cornerRadius: 18)
        }
        .buttonStyle(CapiaTapStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SetupCopy.kindLabel(kind))
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Traços SVG dos tipos de conta do quadro, em uma caixa 24 × 24.
struct AccountKindIcon: Shape {
    let kind: AccountKind

    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
        func line(_ points: CGPoint...) {
            path.move(to: points[0])
            for point in points.dropFirst() { path.addLine(to: point) }
        }
        switch kind {
        case .checking:
            // M3 10l9-6 9 6 M5 10v9 M19 10v9 M9 10v9 M15 10v9 M3 21h18
            line(p(3, 10), p(12, 4), p(21, 10))
            for x in [5.0, 19, 9, 15] { line(p(x, 10), p(x, 19)) }
            line(p(3, 21), p(21, 21))
        case .savings:
            // M5 11a7 6 0 0 1 14 0v5H5z M9 16v4 M15 16v4 M17 9l3-2 M12 5V3
            path.move(to: p(5, 11))
            path.addRelativeArc(center: .zero, radius: 7, startAngle: .degrees(180), delta: .degrees(180),
                                transform: CGAffineTransform(translationX: 12, y: 11).scaledBy(x: 1, y: 6.0 / 7))
            path.addLine(to: p(19, 16))
            path.addLine(to: p(5, 16))
            path.closeSubpath()
            line(p(9, 16), p(9, 20))
            line(p(15, 16), p(15, 20))
            line(p(17, 9), p(20, 7))
            line(p(12, 5), p(12, 3))
        case .wallet:
            // M3 7h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z M3 7l12-4v4 M17 13h.01
            path.move(to: p(3, 7))
            path.addArc(tangent1End: p(21, 7), tangent2End: p(21, 20), radius: 2)
            path.addArc(tangent1End: p(21, 20), tangent2End: p(3, 20), radius: 2)
            path.addArc(tangent1End: p(3, 20), tangent2End: p(3, 7), radius: 2)
            path.closeSubpath()
            line(p(3, 7), p(15, 3), p(15, 7))
            line(p(17, 13), p(17.01, 13))
        }
        let scale = min(rect.width, rect.height) / 24
        return path.applying(CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}

extension View {
    /// Sublinhado de 2 pt dos campos do quadro: areia; verde com foco.
    func capiaUnderline(focused: Bool) -> some View {
        overlay(alignment: .bottom) {
            Rectangle()
                .fill(focused ? CapiaTheme.action : CapiaTheme.border)
                .frame(height: 2)
                .animation(.easeOut(duration: 0.2), value: focused)
        }
    }
}

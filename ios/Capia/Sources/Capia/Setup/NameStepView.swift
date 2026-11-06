import CapiaFlow
import SwiftUI

/// Etapa 1: "Como podemos te chamar?". O título fica no contêiner.
@MainActor
struct NameStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void
    let submit: () -> Void

    @FocusState private var focused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Nome ou apelido")
                .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .semibold))
                .foregroundStyle(CapiaTheme.secondary)
                .accessibilityHidden(true)
            HStack(alignment: .center, spacing: 8) {
                TextField("", text: Binding(get: { draft.name },
                                            set: { value in edit { $0.name = value } }),
                          prompt: Text("Ex.: Diuli").foregroundStyle(CapiaTheme.placeholder))
                    .font(CapiaFonts.title(30))
                    .foregroundStyle(CapiaTheme.ink)
                    .tint(CapiaTheme.caret)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.continue)
                    .focused($focused)
                    .onSubmit { if draft.isNameValid { submit() } }
                    .accessibilityLabel("Nome ou apelido")
                if draft.isNameValid {
                    checkBadge
                        .transition(reduceMotion ? .opacity : .scale(scale: 0.6).combined(with: .opacity))
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: 60)
            .padding(.trailing, 4)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(focused ? CapiaTheme.action : CapiaTheme.border)
                    .frame(height: 2)
                    .animation(.easeOut(duration: 0.2), value: focused)
            }
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.55), value: draft.isNameValid)
            if draft.isNameOneShort {
                Text("Só mais uma letrinha.")
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.alert)
                    .transition(.opacity)
                    .onAppear {
                        AccessibilityNotification.Announcement("Só mais uma letrinha.").post()
                    }
            }
        }
        .animation(.easeOut(duration: 0.3), value: draft.isNameOneShort)
        .task {
            await Task.yield()
            focused = true
        }
    }

    private var checkBadge: some View {
        Circle()
            .fill(CapiaTheme.action)
            .frame(width: 24, height: 24)
            .overlay(CheckMark().stroke(CapiaTheme.actionText,
                                        style: StrokeStyle(lineWidth: 3.4, lineCap: .round, lineJoin: .round))
                .frame(width: 14, height: 14))
    }
}

/// Traço `M5 12l5 5 9-10` do design, em uma caixa 24 × 24.
struct CheckMark: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 24
        var path = Path()
        path.move(to: CGPoint(x: 5 * scale, y: 12 * scale))
        path.addLine(to: CGPoint(x: 10 * scale, y: 17 * scale))
        path.addLine(to: CGPoint(x: 19 * scale, y: 7 * scale))
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

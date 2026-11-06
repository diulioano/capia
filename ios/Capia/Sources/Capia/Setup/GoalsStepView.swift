import CapiaFlow
import SwiftUI

/// Etapa 2: "{nome}, o que te trouxe aqui?". Seleção múltipla.
@MainActor
struct GoalsStepView: View {
    let draft: SetupDraft
    let edit: ((inout SetupDraft) -> Void) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(SetupGoal.allCases, id: \.self) { goal in
                option(goal, selected: draft.goals.contains(goal))
            }
        }
    }

    private func option(_ goal: SetupGoal, selected: Bool) -> some View {
        Button { edit { $0.toggle(goal) } } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 9)
                    .fill(selected ? CapiaTheme.action : CapiaTheme.paper)
                    .overlay(RoundedRectangle(cornerRadius: 9)
                        .strokeBorder(selected ? CapiaTheme.action : CapiaTheme.border, lineWidth: 2))
                    .overlay {
                        if selected {
                            CheckMark()
                                .stroke(CapiaTheme.actionText,
                                        style: StrokeStyle(lineWidth: 3.4, lineCap: .round, lineJoin: .round))
                                .frame(width: 14, height: 14)
                                .transition(reduceMotion ? .opacity : .scale(scale: 0.6).combined(with: .opacity))
                        }
                    }
                    .frame(width: 26, height: 26)
                Text(SetupCopy.label(goal))
                    .font(CapiaFonts.body(16, weight: .semibold))
                    .foregroundStyle(CapiaTheme.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(minHeight: 60)
            .contentShape(Rectangle())
            .capiaOption(selected: selected, cornerRadius: 18)
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.55), value: selected)
        }
        .buttonStyle(CapiaTapStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SetupCopy.label(goal))
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

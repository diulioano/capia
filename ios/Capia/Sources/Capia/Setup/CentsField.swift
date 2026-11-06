import CapiaFlow
import SwiftUI
import UIKit

/// Campo de valor em reais preenchido da direita para a esquerda, como no design.
/// Usa `UITextField` porque o `TextField` do SwiftUI não reescreve o texto formatado
/// enquanto está em edição: os algarismos ficavam acumulados no fim do texto.
/// Cada tecla é interpretada por `Cents.editing`, e o campo sempre mostra `BRL.format`.
@MainActor
struct CentsField: UIViewRepresentable {
    let value: Cents
    let accessibilityLabel: String
    /// Maior valor aceito; algarismos que passariam dele são ignorados.
    var maxValue: Cents = .max
    var fontSize: CGFloat = 48
    /// Abre o teclado ao aparecer, como nas etapas da configuração.
    var focusOnAppear = true
    let onChange: (Cents) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.borderStyle = .none
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.adjustsFontForContentSizeCategory = true
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 24
        field.tintColor = UIColor(CapiaTheme.caret)
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let base = UIFont(name: "ZenMaruGothic-Bold", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .bold)
        let monospaced = base.fontDescriptor.addingAttributes([
            .featureSettings: [[UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                                UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector]]
        ])
        field.font = UIFontMetrics(forTextStyle: .largeTitle)
            .scaledFont(for: UIFont(descriptor: monospaced, size: fontSize))
        apply(to: field)
        // Abre o teclado ao entrar na etapa, como antes.
        if focusOnAppear { DispatchQueue.main.async { field.becomeFirstResponder() } }
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        apply(to: field)
    }

    private func apply(to field: UITextField) {
        let text = BRL.format(value)
        if field.text != text { field.text = text }
        field.textColor = UIColor(value == .zero ? CapiaTheme.placeholder : CapiaTheme.ink)
        field.accessibilityLabel = accessibilityLabel
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CentsField

        init(_ parent: CentsField) { self.parent = parent }

        func textField(_ field: UITextField, shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            let length = (field.text ?? "").utf16.count
            let replacingAll = length > 0 && range.location == 0 && range.length == length
            let edited = parent.value.editing(insert: string, replacingAll: replacingAll)
            let updated = edited > parent.maxValue ? parent.value : edited
            field.text = BRL.format(updated)
            field.textColor = UIColor(updated == .zero ? CapiaTheme.placeholder : CapiaTheme.ink)
            moveCaretToEnd(field)
            if updated != parent.value { parent.onChange(updated) }
            return false
        }

        /// O valor sempre cresce pela direita; o cursor fica no fim do texto.
        func textFieldDidChangeSelection(_ field: UITextField) {
            guard let selection = field.selectedTextRange,
                  selection.isEmpty,
                  selection.start != field.endOfDocument else { return }
            moveCaretToEnd(field)
        }

        private func moveCaretToEnd(_ field: UITextField) {
            let end = field.endOfDocument
            field.selectedTextRange = field.textRange(from: end, to: end)
        }
    }
}

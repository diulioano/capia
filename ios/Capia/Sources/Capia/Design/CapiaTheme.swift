import CapiaFlow
import SwiftUI

enum CapiaTheme {
    static let paper = Color(red: 255/255, green: 252/255, blue: 245/255)
    static let sand = Color(red: 241/255, green: 230/255, blue: 210/255)
    static let terracotta = Color(red: 196/255, green: 98/255, blue: 46/255)
    static let teal = Color(red: 111/255, green: 167/255, blue: 152/255)
    static let cream = Color(red: 251/255, green: 244/255, blue: 229/255)
    static let ink = Color(red: 46/255, green: 42/255, blue: 37/255)
    static let secondary = Color(red: 94/255, green: 86/255, blue: 77/255)
    static let action = Color(red: 92/255, green: 107/255, blue: 52/255)
    static let actionText = Color(red: 251/255, green: 247/255, blue: 240/255)

    // Configuração inicial (quadro fe19fbe7-038d-4ef6-bb17-aedea28b4d3f).
    static let border = Color(hex: 0xE5D6BE)
    static let selection = Color(hex: 0xECEBD6)
    static let track = Color(hex: 0xE8DBC6)
    static let inactive = Color(hex: 0xDDD3C4)
    static let muted = Color(hex: 0x6B6258)
    static let placeholder = Color(hex: 0x9A8F82)
    static let tipText = Color(hex: 0x4A433B)
    static let alert = Color(hex: 0x9C4A22)
    static let notice = Color(hex: 0x45512A)
    static let errorBackground = Color(hex: 0xFADDCB)
    static let errorText = Color(hex: 0x84401E)
    static let celebration = Color(hex: 0xF1E8DA)
    static let caret = terracotta

    // Resumo do mês (quadro 333f2428-5004-43ff-b703-276a4524089b).
    static let water = Color(hex: 0x9CC7BA)
    static let foam = Color(hex: 0xBEDCD2)
    static let divider = Color(hex: 0xF4EBDC)
    static let expenseChip = Color(hex: 0xFBE3CF)
    static let tabBar = Color(hex: 0xF6F0E6)
    static let badge = Color(hex: 0xFFFDF8)
    static let balanceText = Color(hex: 0x3E3A34)
    static let shadow = Color(red: 80/255, green: 60/255, blue: 40/255)

    // Quadro "Novo registro".
    static let keyPressed = Color(hex: 0xE5D6BE)
    static let toastBackground = ink
    static let toastText = Color(hex: 0xFBF7F0)
    static let toastSecondary = Color(hex: 0xD8CFC2)
    static let toastAction = Color(hex: 0xF2C9A7)

    /// Cor de cada categoria (ponto da ficha, inicial dos recentes, barra de "Para onde foi").
    static func category(_ category: RecordCategory) -> Color {
        switch category {
        case .market: Color(hex: 0x5C6B34)
        case .restaurants: Color(hex: 0xC4622E)
        case .transport: Color(hex: 0xC9A472)
        case .home: Color(hex: 0x6FA798)
        case .leisure: Color(hex: 0xD99A3C)
        case .health: Color(hex: 0xA8957A)
        case .shopping: Color(hex: 0xB07A93)
        case .other: Color(hex: 0x9A8F82)
        }
    }

    /// Cores das receitas em "Para onde foi", na ordem do quadro "Resumo do mês".
    static func income(at index: Int) -> Color {
        let colors = [Color(hex: 0x5C6B34), Color(hex: 0x6FA798), Color(hex: 0xC9A472)]
        return colors.indices.contains(index) ? colors[index] : Color(hex: 0x9A8F82)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

/// Toque com leve redução, como `.tap:active` do design.
struct CapiaTapStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

/// Opção selecionável da configuração: creme com borda areia; selecionada, verde claro.
struct CapiaOptionBackground: ViewModifier {
    let selected: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(selected ? CapiaTheme.selection : CapiaTheme.paper,
                        in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(selected ? CapiaTheme.action : CapiaTheme.border, lineWidth: 2))
            .animation(.easeOut(duration: 0.2), value: selected)
    }
}

extension View {
    func capiaOption(selected: Bool, cornerRadius: CGFloat) -> some View {
        modifier(CapiaOptionBackground(selected: selected, cornerRadius: cornerRadius))
    }

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

/// Continuar da configuração: verde quando disponível; areia quando indisponível.
struct CapiaContinueButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 58)
            .foregroundStyle(isEnabled ? CapiaTheme.actionText : CapiaTheme.muted)
            .background(isEnabled ? CapiaTheme.action : CapiaTheme.inactive,
                        in: RoundedRectangle(cornerRadius: 20))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}

struct CapiaPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 58)
            .foregroundStyle(CapiaTheme.actionText)
            .background(CapiaTheme.action, in: RoundedRectangle(cornerRadius: 20))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .shadow(color: .black.opacity(0.18), radius: 13, y: 10)
    }
}

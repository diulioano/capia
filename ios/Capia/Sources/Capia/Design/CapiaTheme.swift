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

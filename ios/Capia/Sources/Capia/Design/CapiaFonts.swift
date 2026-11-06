import CoreText
import SwiftUI

@MainActor
enum CapiaFonts {
    static func register() {
        for name in ["Figtree-Regular", "Figtree-SemiBold", "Figtree-Bold", "ZenMaruGothic-Bold"] {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                preconditionFailure("Fonte empacotada ausente: \(name)")
            }
            var error: Unmanaged<CFError>?
            let registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            precondition(registered, "Não foi possível registrar a fonte \(name)")
        }
    }

    static func body(_ size: CGFloat = 16, relativeTo style: Font.TextStyle = .body,
                     weight: Font.Weight = .regular) -> Font {
        let name = weight == .bold ? "Figtree-Bold" : weight == .semibold ? "Figtree-SemiBold" : "Figtree-Regular"
        return .custom(name, size: size, relativeTo: style)
    }

    static func title(_ size: CGFloat = 34) -> Font {
        .custom("ZenMaruGothic-Bold", size: size, relativeTo: .largeTitle)
    }
}

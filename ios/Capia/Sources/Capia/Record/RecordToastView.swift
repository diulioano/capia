import SwiftUI

/// Aviso escuro do quadro: capivara comemorando, título e resumo do registro salvo.
@MainActor
struct RecordToastView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 8) {
            Image(uiImage: CapiaImages.celebratingCapybara)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CapiaFonts.body(15, relativeTo: .subheadline, weight: .bold))
                    .foregroundStyle(CapiaTheme.toastText)
                Text(subtitle)
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .monospacedDigit()
                    .foregroundStyle(CapiaTheme.toastSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.leading, 6)
        .padding(.trailing, 10)
        .background(CapiaTheme.toastBackground, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color(red: 40/255, green: 30/255, blue: 20/255).opacity(0.3), radius: 15, y: 14)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .onAppear {
            AccessibilityNotification.Announcement("\(title). \(subtitle)").post()
        }
    }
}

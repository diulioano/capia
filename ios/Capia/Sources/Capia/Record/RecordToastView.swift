import SwiftUI

/// Aviso escuro do quadro: capivara, título, resumo opcional e uma ação ("Desfazer" no
/// registro salvo, "Tentar de novo" na falha de gravação).
@MainActor
struct RecordToastView: View {
    let image: UIImage
    let title: String
    let subtitle: String?
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CapiaFonts.body(15, relativeTo: .subheadline, weight: .bold))
                    .foregroundStyle(CapiaTheme.toastText)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(CapiaFonts.body(13, relativeTo: .caption))
                        .monospacedDigit()
                        .foregroundStyle(CapiaTheme.toastSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            Button(actionTitle, action: action)
                .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .bold))
                .foregroundStyle(CapiaTheme.toastAction)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .buttonStyle(CapiaTapStyle())
                .fixedSize()
        }
        .padding(.vertical, 8)
        .padding(.leading, 6)
        .padding(.trailing, 10)
        .background(CapiaTheme.toastBackground, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color(red: 40/255, green: 30/255, blue: 20/255).opacity(0.3), radius: 15, y: 14)
        .accessibilityElement(children: .contain)
        .onAppear {
            let spoken = [title, subtitle].compactMap { $0 }.joined(separator: ". ")
            AccessibilityNotification.Announcement(spoken).post()
        }
    }
}

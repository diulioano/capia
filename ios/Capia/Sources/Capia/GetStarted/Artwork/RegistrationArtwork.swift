import SwiftUI

struct RegistrationArtwork: View {
    var body: some View {
        ArtworkPanel(background: Color(red: 237/255, green: 226/255, blue: 208/255),
                     summary: "Capivara pensando, com opções ilustrativas Digitar, Falar e Foto do recibo.") {
            ZStack(alignment: .topLeading) {
                Image(uiImage: CapiaImages.thinkingCapybara)
                    .resizable().scaledToFit()
                    .frame(width: 200, height: 200, alignment: .bottom)
                    .offset(x: 75, y: 204)
                chip("Digitar", symbol: "keyboard", color: CapiaTheme.action)
                    .modifier(ArtworkFloat()).offset(x: 22, y: 46)
                chip("Falar", symbol: "mic", color: CapiaTheme.terracotta)
                    .modifier(ArtworkFloat(phase: 0.9))
                    .frame(width: 306, alignment: .trailing).offset(x: 22, y: 84)
                chip("Foto do recibo", symbol: "camera", color: CapiaTheme.action)
                    .modifier(ArtworkFloat(phase: 1.8)).offset(x: 26, y: 146)
            }
            .frame(width: 350, height: 400, alignment: .topLeading)
        }
    }

    private func chip(_ title: String, symbol: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(color)
            Text(title).font(CapiaFonts.body(15, weight: .semibold))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .brown.opacity(0.12), radius: 11, y: 8)
    }
}

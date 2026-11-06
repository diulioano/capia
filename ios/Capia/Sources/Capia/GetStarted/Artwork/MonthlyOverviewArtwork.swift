import SwiftUI

struct MonthlyOverviewArtwork: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ArtworkPanel(background: Color(red: 234/255, green: 235/255, blue: 218/255),
                     summary: "Novembro. Mercado 35%, Restaurantes 20%, Transporte 13%, Lazer 11%. Categorias parciais de um resumo ilustrativo, com capivara feliz.") {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Novembro").font(CapiaFonts.body(16, weight: .bold))
                        Spacer()
                        Text("para onde foi").font(CapiaFonts.body(13)).foregroundStyle(CapiaTheme.secondary)
                    }
                    bar("Mercado", value: 35, color: CapiaTheme.action, delay: 0)
                    bar("Restaurantes", value: 20, color: CapiaTheme.terracotta, delay: 0.15)
                    bar("Transporte", value: 13, color: CapiaTheme.teal, delay: 0.3)
                    bar("Lazer", value: 11, color: Color(red: 201/255, green: 164/255, blue: 114/255), delay: 0.45)
                }
                .padding(20).frame(width: 298)
                .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 24))
                .shadow(color: CapiaTheme.action.opacity(0.1), radius: 13, y: 10)
                .offset(x: 26, y: 30)
                Image(uiImage: CapiaImages.happyCapybara)
                    .resizable().scaledToFit().frame(width: 140, height: 140, alignment: .bottom)
                    .modifier(ArtworkFloat()).offset(x: 196, y: 278)
            }
            .frame(width: 350, height: 400, alignment: .topLeading)
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }

    private func bar(_ title: String, value: Int, color: Color, delay: Double) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value)%").monospacedDigit()
            }
            .font(CapiaFonts.body(14))
            GeometryReader { geometry in
                Capsule().fill(CapiaTheme.sand)
                Capsule().fill(color)
                    .frame(width: geometry.size.width * Double(value) / 100)
                    .scaleEffect(x: appeared || reduceMotion ? 1 : 0, anchor: .leading)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.7).delay(delay), value: appeared)
            }
            .frame(height: 10)
        }
    }
}

import SwiftUI

struct GoalsArtwork: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ArtworkPanel(background: Color(red: 241/255, green: 225/255, blue: 211/255),
                     summary: "Meta ilustrativa Viagem ao Japão. 68%. R$ 12.240 de R$ 18.000, com capivara comemorando.") {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottom) {
                    Color(red: 248/255, green: 242/255, blue: 232/255)
                    Color(red: 127/255, green: 179/255, blue: 165/255)
                        .frame(height: 184 * 0.68)
                        .overlay(alignment: .top) {
                            TimelineView(.animation(paused: reduceMotion || !appeared)) { context in
                                Canvas { canvas, size in
                                    let phase = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                                    var wave = Path()
                                    wave.move(to: CGPoint(x: 0, y: size.height))
                                    for x in stride(from: 0.0, through: Double(size.width), by: 2) {
                                        wave.addLine(to: CGPoint(x: x, y: 6 + sin(x / 24 + phase) * 3))
                                    }
                                    wave.addLine(to: CGPoint(x: size.width, y: size.height))
                                    wave.closeSubpath()
                                    canvas.fill(wave, with: .color(Color(red: 127/255, green: 179/255, blue: 165/255)))
                                }
                            }
                            .frame(height: 12).offset(y: -9)
                        }
                        .scaleEffect(y: appeared || reduceMotion ? 1 : 0, anchor: .bottom)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.9), value: appeared)
                    Text("68%")
                        .font(CapiaFonts.title(38))
                        .frame(maxHeight: .infinity)
                }
                .frame(width: 184, height: 184)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(8)
                .background(Color(red: 165/255, green: 123/255, blue: 82/255), in: RoundedRectangle(cornerRadius: 40))
                .offset(x: 40, y: 70)
                Text("Viagem ao Japão").font(CapiaFonts.body(16, weight: .bold)).offset(x: 40, y: 290)
                Text("R$ 12.240 de R$ 18.000").font(CapiaFonts.body(14))
                    .foregroundStyle(CapiaTheme.secondary).offset(x: 40, y: 314)
                Image(uiImage: CapiaImages.celebratingCapybara)
                    .resizable().scaledToFit().frame(width: 150, height: 150, alignment: .bottom)
                    .modifier(ArtworkFloat()).offset(x: 210, y: 256)
            }
            .frame(width: 350, height: 400, alignment: .topLeading)
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}

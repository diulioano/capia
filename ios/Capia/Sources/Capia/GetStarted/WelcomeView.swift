import SwiftUI
import UIKit

@MainActor
struct WelcomeView: View {
    let start: () -> Void
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var feedback = false
    @State private var feedbackTask: Task<Void, Never>?
    @State private var visible = false
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            if textSize.isAccessibilitySize || geometry.size.height < 620 {
                ScrollView {
                    VStack(spacing: 24) {
                        copy
                            .padding(.horizontal, 28)
                        scene
                            .frame(height: 360)
                            .clipped()
                        startButton
                            .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 24)
                }
                .background(CapiaTheme.cream)
            } else {
                ZStack {
                    scene.ignoresSafeArea()
                    VStack {
                        copy.padding(.horizontal, 28)
                        Spacer(minLength: 20)
                        startButton.padding(.horizontal, 24)
                    }
                    .padding(.top, max(20, 76 - geometry.safeAreaInsets.top))
                    .padding(.bottom, max(6, 40 - geometry.safeAreaInsets.bottom))
                }
            }
        }
        .foregroundStyle(CapiaTheme.ink)
        .onAppear {
            visible = true
            titleFocused = true
        }
        .onDisappear {
            visible = false
            feedbackTask?.cancel()
            feedbackTask = nil
            feedback = false
        }
    }

    private var copy: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Boas-vindas ao seu refúgio".uppercased())
                .font(CapiaFonts.body(13, relativeTo: .caption, weight: .semibold))
                .tracking(1.56)
                .foregroundStyle(CapiaTheme.secondary)
            Text("Seu dinheiro em águas calmas.")
                .font(CapiaFonts.title())
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)
            Text("Registre gastos, entenda o mês e guarde para o que importa, sem planilha e sem pressa.")
                .font(CapiaFonts.body())
                .lineSpacing(5)
                .foregroundStyle(CapiaTheme.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: "checkmark").accessibilityHidden(true)
                Text("Não precisa criar conta")
            }
            .font(CapiaFonts.body(13, relativeTo: .caption, weight: .semibold))
            .foregroundStyle(CapiaTheme.action)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var startButton: some View {
        Button("Começar", action: start).buttonStyle(CapiaPrimaryButtonStyle())
    }

    private var scene: some View {
        GeometryReader { geometry in
            let scale = max(geometry.size.width / 390, geometry.size.height / 844)
            let offsetX = (geometry.size.width - 390 * scale) / 2
            let offsetY = geometry.size.height < 620
                ? geometry.size.height - 744 * scale
                : (geometry.size.height - 844 * scale) / 2
            ZStack(alignment: .topLeading) {
                Image("OnsenWallpaper", bundle: .module)
                    .resizable()
                    .frame(width: 390 * scale, height: 844 * scale)
                    .offset(x: offsetX, y: offsetY)
                    .accessibilityHidden(true)
                TimelineView(.animation(paused: reduceMotion || !visible)) { context in
                    let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                    Canvas { canvas, size in
                        for (x, y, phase) in [(70.0, 548.0, 0.0), (290, 560, 1.7), (196, 520, 3.3)] {
                            let wave = reduceMotion ? 0.5 : (sin((time + phase) * .pi / 3) + 1) / 2
                            var path = Path()
                            path.move(to: CGPoint(x: x + 20, y: y + 100 - wave * 8))
                            path.addCurve(to: CGPoint(x: x + 20, y: y + 8 - wave * 8),
                                          control1: CGPoint(x: x - 6, y: y + 70),
                                          control2: CGPoint(x: x + 44, y: y + 38))
                            canvas.stroke(path, with: .color(.white.opacity(0.25 + wave * 0.35)),
                                          style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        }
                        let glints: [(Double, Double, Double)] = [(40,650,18),(96,700,12),(262,660,22),(318,712,14),(70,752,20),(236,770,16),(330,640,10),(176,736,12),(120,790,18),(286,800,12)]
                        for (index, glint) in glints.enumerated() {
                            let opacity = reduceMotion ? 0.4 : (sin(time * 2 + Double(index)) + 1) * 0.4
                            canvas.fill(Path(ellipseIn: CGRect(x: glint.0, y: glint.1, width: glint.2, height: 3)),
                                        with: .color(CapiaTheme.actionText.opacity(opacity)))
                        }
                        for phase in [0.0, 2.2] {
                            let progress = reduceMotion ? 0.3 : (time + phase).truncatingRemainder(dividingBy: 4.4) / 4.4
                            let width = 76 * (0.85 + progress * 0.7)
                            let rect = CGRect(x: 206 - width/2, y: 662 - progress * 2, width: width, height: 11 + progress * 4)
                            canvas.stroke(Path(ellipseIn: rect), with: .color(.white.opacity((1-progress) * 0.75)),
                                          style: StrokeStyle(lineWidth: 1.5, dash: [1, 3]))
                        }
                        canvas.fill(Path(ellipseIn: CGRect(x: 172, y: 664, width: 68, height: 4)),
                                    with: .color(CapiaTheme.actionText.opacity(0.55)))
                        canvas.fill(Path(ellipseIn: CGRect(x: 248, y: 660, width: 9, height: 9)),
                                    with: .color(Color(red: 217/255, green: 154/255, blue: 60/255)))
                    }
                }
                .frame(width: 390, height: 844)
                .scaleEffect(scale, anchor: .topLeading)
                .offset(x: offsetX, y: offsetY)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

                mascot
                    .scaleEffect(y: -1)
                    .opacity(0.2)
                    .mask(LinearGradient(colors: [.black, .clear, .clear], startPoint: .top, endPoint: .bottom))
                    .frame(width: 72 * scale, height: 61 * scale)
                    .offset(x: offsetX + 170 * scale, y: offsetY + 667 * scale)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
                Button(action: pet) {
                    mascot
                        .mask(LinearGradient(stops: [.init(color: .black, location: 0), .init(color: .black, location: 0.74), .init(color: .clear, location: 1)], startPoint: .top, endPoint: .bottom))
                }
                .buttonStyle(.plain)
                .frame(width: max(44, 72 * scale), height: max(44, 61 * scale))
                .contentShape(Rectangle())
                .accessibilityLabel("Fazer carinho na capivara")
                .offset(x: offsetX + 170 * scale, y: offsetY + 607 * scale)
                if feedback {
                    Text("Que bom te ver aqui.")
                        .font(CapiaFonts.body(14, relativeTo: .callout, weight: .semibold))
                        .padding(12)
                        .background(CapiaTheme.actionText, in: RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.18), radius: 9, y: 6)
                        .frame(maxWidth: geometry.size.width - 48)
                        .fixedSize(horizontal: false, vertical: true)
                        .position(x: geometry.size.width / 2, y: offsetY + 570 * scale)
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    private var mascot: some View {
        TimelineView(.animation(paused: reduceMotion || !visible)) { context in
            let phase = reduceMotion ? 0 : sin(context.date.timeIntervalSinceReferenceDate * .pi / 2)
            Image("WelcomeCapybara", bundle: .module).resizable().scaledToFit()
                .offset(y: phase * 0.75)
        }
    }

    private func pet() {
        feedbackTask?.cancel()
        feedback = true
        UIAccessibility.post(notification: .announcement, argument: "Que bom te ver aqui.")
        feedbackTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(1900))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            feedback = false
            feedbackTask = nil
        }
    }
}

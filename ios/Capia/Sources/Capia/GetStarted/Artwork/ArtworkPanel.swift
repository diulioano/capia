import SwiftUI

struct ArtworkPanel<Content: View>: View {
    let background: Color
    let summary: String
    @ViewBuilder let content: Content
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    content
                        .frame(width: 350, height: 400)
                        .scaleEffect(geometry.size.width / 350, anchor: .topLeading)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                    Text("Exemplo")
                        .font(CapiaFonts.body(11, relativeTo: .caption))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(CapiaTheme.paper, in: Capsule())
                        .padding(12)
                }
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 32))
            }
            .aspectRatio(350.0 / 400, contentMode: .fit)
            .dynamicTypeSize(.medium)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Exemplo. \(summary)")
            .accessibilityHidden(textSize.isAccessibilitySize)
            if textSize.isAccessibilitySize {
                Text("Exemplo. \(summary)")
                    .font(CapiaFonts.body())
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ArtworkFloat: ViewModifier {
    var phase: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false

    func body(content: Content) -> some View {
        TimelineView(.animation(paused: reduceMotion || !visible)) { context in
            let displacement = reduceMotion ? 0 : sin(context.date.timeIntervalSinceReferenceDate * .pi / 2 + phase) * 2
            content.offset(y: displacement)
        }
        .onAppear { visible = true }
        .onDisappear { visible = false }
    }
}

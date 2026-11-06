import SwiftUI

/// Ícones de traço do quadro "Resumo do mês", desenhados na grade 24 × 24 dos SVGs.
struct HomeIcon: Shape {
    enum Kind {
        /// `M12 19V5M6 11l6-6 6 6`
        case arrowUp
        /// `M12 5v14M6 13l6 6 6-6`
        case arrowDown
        /// `rect 2,5 20×14 rx3` e `M2 10h20`
        case card
        /// `M12 5v14M5 12h14`
        case plus
    }

    let kind: Kind

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 24
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * s, y: rect.minY + y * s)
        }
        var path = Path()
        switch kind {
        case .arrowUp:
            path.move(to: p(12, 19)); path.addLine(to: p(12, 5))
            path.move(to: p(6, 11)); path.addLine(to: p(12, 5)); path.addLine(to: p(18, 11))
        case .arrowDown:
            path.move(to: p(12, 5)); path.addLine(to: p(12, 19))
            path.move(to: p(6, 13)); path.addLine(to: p(12, 19)); path.addLine(to: p(18, 13))
        case .card:
            path.addRoundedRect(in: CGRect(origin: p(2, 5), size: CGSize(width: 20 * s, height: 14 * s)),
                                cornerSize: CGSize(width: 3 * s, height: 3 * s))
            path.move(to: p(2, 10)); path.addLine(to: p(22, 10))
        case .plus:
            path.move(to: p(12, 5)); path.addLine(to: p(12, 19))
            path.move(to: p(5, 12)); path.addLine(to: p(19, 12))
        }
        return path
    }
}

extension HomeIcon {
    /// Ícone de traço com a espessura do SVG (na grade de 24) e pontas arredondadas.
    func icon(size: CGFloat, color: Color, lineWidth: CGFloat) -> some View {
        stroke(color, style: StrokeStyle(lineWidth: lineWidth * size / 24, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

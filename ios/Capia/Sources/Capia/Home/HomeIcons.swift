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
        /// `M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z`
        case house
        /// Tigela de onsen: `M4 10h16v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4z` e vapor
        /// `M9 6c0-1.5 1-2 1-3M14 6c0-1.5 1-2 1-3`. O vapor só é traçado, nunca preenchido.
        case bowl
        /// Só a tigela, para o preenchimento do item atual.
        case bowlBody
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
        case .house:
            path.move(to: p(3, 11)); path.addLine(to: p(12, 4)); path.addLine(to: p(21, 11))
            path.addLine(to: p(21, 20))
            path.addQuadCurve(to: p(20, 21), control: p(21, 21))
            path.addLine(to: p(15, 21)); path.addLine(to: p(15, 15)); path.addLine(to: p(9, 15))
            path.addLine(to: p(9, 21)); path.addLine(to: p(4, 21))
            path.addQuadCurve(to: p(3, 20), control: p(3, 21))
            path.closeSubpath()
        case .bowl, .bowlBody:
            path.move(to: p(4, 10)); path.addLine(to: p(20, 10)); path.addLine(to: p(20, 16))
            path.addArc(center: p(16, 16), radius: 4 * s, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: p(8, 20))
            path.addArc(center: p(8, 16), radius: 4 * s, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.closeSubpath()
            if kind == .bowl {
                for x in [CGFloat(9), 14] {
                    path.move(to: p(x, 6))
                    path.addCurve(to: p(x + 1, 3), control1: p(x, 4.5), control2: p(x + 1, 4))
                }
            }
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

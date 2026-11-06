import CapiaFlow
import SwiftUI

/// Cartão do saldo: água no nível da parte disponível das receitas, duas ondas, vapor,
/// saldo do mês com contagem, sobra prevista e selo. Lido como um único resumo.
@MainActor
struct BalanceCardView: View {
    let totals: MonthTotals
    /// Saldos iniciais mais salários recebidos: dinheiro nas contas, não sobra do mês.
    /// Dinheiro nas contas hoje, com sinal: pode ficar negativo depois de gastos.
    let accountsBalance: Int64
    let hidden: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shownBalance: Double = 0
    @State private var level: Double = MonthTotals.minimumWaterLevel

    var body: some View {
        content
            .frame(maxWidth: .infinity, minHeight: 214, alignment: .topLeading)
            .background(alignment: .bottom) { water }
            .background(CapiaTheme.sand)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenSummary)
            .onAppear { update(animated: !reduceMotion) }
            .onChange(of: totals) { update(animated: !reduceMotion) }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(HomeCopy.balanceTitle)
                .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .semibold))
                .foregroundStyle(CapiaTheme.tipText)
            Group {
                if hidden {
                    Text(BRL.hidden)
                } else {
                    Text(BRL.format(signed: totals.balance))
                        .modifier(CountingBalance(value: shownBalance))
                }
            }
            .font(CapiaFonts.title(40))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            Text("\(HomeCopy.forecastTitle) \(Text(HomeCopy.money(signed: totals.forecastBalance, hidden: hidden)).bold())")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .monospacedDigit()
                .foregroundStyle(CapiaTheme.balanceText)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(HomeCopy.accountsTitle) \(Text(HomeCopy.money(signed: accountsBalance, hidden: hidden)).bold())")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .monospacedDigit()
                .foregroundStyle(CapiaTheme.balanceText)
                .fixedSize(horizontal: false, vertical: true)
            Text(HomeCopy.availableBadge(totals, hidden: hidden))
                .font(CapiaFonts.body(13, relativeTo: .caption, weight: .semibold))
                .foregroundStyle(CapiaTheme.notice)
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(CapiaTheme.badge.opacity(0.82), in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 10)
        }
        .padding(22)
    }

    private var water: some View {
        GeometryReader { geometry in
            let height = geometry.size.height * level
            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        ZStack(alignment: .top) {
                            Wave()
                                .fill(CapiaTheme.foam)
                                .frame(width: 700, height: 18)
                                .offset(x: -350 + wavePhase(time, period: 12) * 350, y: -14)
                            Wave()
                                .fill(CapiaTheme.water)
                                .frame(width: 700, height: 18)
                                .offset(x: -wavePhase(time, period: 7) * 350, y: -10)
                            CapiaTheme.water
                                .frame(height: height)
                        }
                        .frame(width: geometry.size.width, height: height, alignment: .topLeading)
                    }
                    if !reduceMotion {
                        Steam(phase: steamPhase(time, delay: 0))
                            .padding(.trailing, 70).padding(.bottom, 60)
                        Steam(phase: steamPhase(time, delay: 2.2))
                            .padding(.trailing, 30).padding(.bottom, 50)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
        .accessibilityHidden(true)
    }

    /// Fração do ciclo linear da onda, de 0 a 1.
    private func wavePhase(_ time: TimeInterval, period: Double) -> CGFloat {
        CGFloat(time.truncatingRemainder(dividingBy: period) / period)
    }

    /// Fração do ciclo de 5 s do vapor, com atraso inicial.
    private func steamPhase(_ time: TimeInterval, delay: Double) -> Double {
        let shifted = time - delay
        let cycle = shifted.truncatingRemainder(dividingBy: 5)
        return (cycle < 0 ? cycle + 5 : cycle) / 5
    }

    private func update(animated: Bool) {
        let target = Double(totals.balance)
        let targetLevel = totals.waterLevel
        if animated {
            withAnimation(.timingCurve(0.33, 1, 0.68, 1, duration: 0.8)) { shownBalance = target }
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.1)) { level = targetLevel }
        } else {
            shownBalance = target
            level = targetLevel
        }
    }

    private var spokenSummary: String {
        let balance = HomeCopy.spoken(BRL.format(signed: totals.balance), hidden: hidden)
        let forecast = HomeCopy.spoken(BRL.format(signed: totals.forecastBalance), hidden: hidden)
        let accounts = HomeCopy.spoken(BRL.format(signed: accountsBalance), hidden: hidden)
        return "\(HomeCopy.balanceTitle), \(balance). Sobra prevista no fim do mês, \(forecast). "
            + "Em contas hoje, \(accounts). " + HomeCopy.availableBadge(totals, hidden: hidden)
    }
}

/// Exibe o saldo durante a contagem até o valor final, em centavos inteiros.
private struct CountingBalance: ViewModifier, Animatable {
    var value: Double

    nonisolated var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        Text(BRL.format(signed: Int64(value.rounded())))
    }
}

/// Onda do quadro: `M0 12 Q43.75 2 87.5 12 T175 12 … T700 12 V18 H0Z` em 700 × 18.
private struct Wave: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 700, sy = rect.height / 18
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 12 * sy))
        for i in 0..<8 {
            let start = CGFloat(i) * 87.5
            path.addQuadCurve(to: CGPoint(x: (start + 87.5) * sx, y: 12 * sy),
                              control: CGPoint(x: (start + 43.75) * sx, y: (i.isMultiple(of: 2) ? 2 : 22) * sy))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

/// Vapor do quadro: `M15 66 C4 52 26 42 15 28 S6 8 15 2`, branco, 5 pt, desfocado.
/// Sobe 48 pt, alarga 30% e aparece até 0,55 aos 35% do ciclo.
private struct Steam: View {
    let phase: Double

    var body: some View {
        let eased = 0.5 - cos(phase * .pi) / 2
        let opacity = phase < 0.35 ? phase / 0.35 * 0.55 : (1 - phase) / 0.65 * 0.55
        SteamPath()
            .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .frame(width: 30, height: 70)
            .blur(radius: 1.2)
            .scaleEffect(x: 1 + 0.3 * eased, y: 1)
            .offset(y: 8 - 48 * eased)
            .opacity(opacity)
    }

    private struct SteamPath: Shape {
        func path(in rect: CGRect) -> Path {
            let sx = rect.width / 30, sy = rect.height / 70
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }
            var path = Path()
            path.move(to: p(15, 66))
            path.addCurve(to: p(15, 28), control1: p(4, 52), control2: p(26, 42))
            path.addCurve(to: p(15, 2), control1: p(4, 14), control2: p(6, 8))
            return path
        }
    }
}

import CapiaFlow
import SwiftUI

/// Conclusão da configuração: capivara comemorando, confete, resumo das contas e
/// cartões da sessão, "Ver meu mês" e "Adicionar outra conta".
@MainActor
struct SetupDoneView: View {
    let flow: SetupFlow
    let saveFailed: Bool
    let send: (SetupAction.Intent) -> Void
    let retrySave: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var titleFocused: Bool
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .top) {
            CapiaTheme.celebration.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    Image(uiImage: CapiaImages.celebratingCapybara)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .scaleEffect(appeared || reduceMotion ? 1 : 0.6)
                        .opacity(appeared || reduceMotion ? 1 : 0)
                        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.5), value: appeared)
                        .accessibilityHidden(true)
                    Text(SetupCopy.title(for: .done, draft: flow.draft))
                        .font(CapiaFonts.title(30))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityFocused($titleFocused)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        .modifier(Enter(appeared: appeared, delay: 0))
                    Text("Seu refúgio está montado. Agora é só ir registrando, sem pressa.")
                        .font(CapiaFonts.body(16))
                        .lineSpacing(6)
                        .foregroundStyle(CapiaTheme.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .modifier(Enter(appeared: appeared, delay: 0.1))
                    summary
                        .padding(.top, 24)
                        .modifier(Enter(appeared: appeared, delay: 0.2))
                    if saveFailed { saveWarning.padding(.top, 14) }
                }
                .padding(.top, flow.canGoBack ? 8 : 22)
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
            }
            if !reduceMotion { Confetti().allowsHitTesting(false).accessibilityHidden(true) }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if flow.canGoBack {
                HStack {
                    Button { send(.back) } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(CapiaTheme.ink)
                            .frame(width: 44, height: 44)
                            .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(CapiaTapStyle())
                    .accessibilityLabel("Voltar")
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 8) {
                Button("Ver meu mês") { send(.viewMonth) }
                    .buttonStyle(CapiaContinueButtonStyle())
                Button { send(.addAnotherAccount) } label: {
                    Text("Adicionar outra conta")
                        .font(CapiaFonts.body(15, weight: .semibold))
                        .foregroundStyle(CapiaTheme.action)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(CapiaTapStyle())
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .background(CapiaTheme.celebration)
        }
        .onAppear { appeared = true }
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }

    // MARK: Resumo

    private var summary: some View {
        VStack(spacing: 0) {
            ForEach(Array(flow.accounts.enumerated()), id: \.element.id) { index, account in
                row(title: account.name, detail: SetupCopy.kindDescription(account.kind)) {
                    Text(BRL.format(account.initialBalance))
                        .font(CapiaFonts.body(16, weight: .bold))
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Conta \(account.name), \(SetupCopy.kindDescription(account.kind)), saldo inicial \(BRL.format(account.initialBalance))")
                divider(after: index, total: flow.accounts.count + max(flow.cards.count, 1))
            }
            if flow.cards.isEmpty {
                Text("Sem cartão por enquanto.")
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
            } else {
                ForEach(Array(flow.cards.enumerated()), id: \.element.id) { index, card in
                    row(title: "Cartão \(card.name)",
                        detail: "Fecha dia \(card.closingDay) · vence dia \(card.dueDay)") {
                        Text("Separado")
                            .font(CapiaFonts.body(13, relativeTo: .caption, weight: .bold))
                            .foregroundStyle(CapiaTheme.notice)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(CapiaTheme.selection, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Cartão de crédito \(card.name), fecha dia \(card.closingDay), vence dia \(card.dueDay), separado da conta")
                    divider(after: flow.accounts.count + index, total: flow.accounts.count + flow.cards.count)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 18)
        .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color(red: 80/255, green: 60/255, blue: 40/255).opacity(0.08), radius: 12, y: 8)
    }

    private func row<Trailing: View>(title: String, detail: String,
                                     @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CapiaFonts.body(16, weight: .bold))
                Text(detail)
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            trailing()
        }
        .foregroundStyle(CapiaTheme.ink)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func divider(after index: Int, total: Int) -> some View {
        if index < total - 1 {
            Rectangle().fill(Color(hex: 0xF4EBDC)).frame(height: 1)
        }
    }

    private var saveWarning: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Não consegui guardar no aparelho. Seus dados ficam só até fechar o app.")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.errorText)
                .fixedSize(horizontal: false, vertical: true)
            Button("Tentar de novo", action: retrySave)
                .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .bold))
                .foregroundStyle(CapiaTheme.errorText)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(CapiaTheme.errorBackground, in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            AccessibilityNotification.Announcement("Não consegui guardar no aparelho.").post()
        }
    }
}

/// Entrada do design: desliza 24 pt e aparece em 0,4 s, com atraso por elemento.
private struct Enter: ViewModifier {
    let appeared: Bool
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared || reduceMotion ? 1 : 0)
            .offset(x: appeared || reduceMotion ? 0 : 24)
            .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4).delay(delay),
                       value: appeared)
    }
}

/// 18 confetes que caem uma vez, nas posições, cores e atrasos do quadro (base 390 pt).
private struct Confetti: View {
    private static let colors: [Color] = [CapiaTheme.action, CapiaTheme.terracotta,
                                          Color(hex: 0xD99A3C), Color(hex: 0x7FB3A5), Color(hex: 0xC9A472)]

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 390
            ForEach(0..<18, id: \.self) { i in
                Piece(color: Self.colors[i % Self.colors.count],
                      width: i % 3 == 0 ? 8 : 10, height: i % 2 == 1 ? 14 : 8,
                      round: i % 3 == 0, delay: Double(i % 6) * 0.12,
                      fall: geometry.size.height + 60)
                    .position(x: (CGFloat((i * 53) % 370) + 6) * scale + 5, y: 0)
            }
        }
        .ignoresSafeArea()
    }

    private struct Piece: View {
        let color: Color
        let width: CGFloat
        let height: CGFloat
        let round: Bool
        let delay: Double
        let fall: CGFloat
        @State private var fallen = false
        @State private var faded = false

        var body: some View {
            RoundedRectangle(cornerRadius: round ? width / 2 : 3)
                .fill(color)
                .frame(width: width, height: height)
                .rotationEffect(.degrees(fallen ? 600 : 0))
                .offset(y: fallen ? fall : -60)
                .opacity(faded ? 0 : 1)
                .onAppear {
                    withAnimation(.timingCurve(0.2, 0.6, 0.4, 1, duration: 2.4).delay(delay)) { fallen = true }
                    withAnimation(.easeIn(duration: 0.48).delay(delay + 1.92)) { faded = true }
                }
        }
    }
}

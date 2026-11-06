import CapiaFlow
import Foundation
import SwiftUI

/// Entrada `pop` do quadro: cresce de 50% com leve rebote. Omitida com redução de movimento.
private struct Pop: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(shown || reduceMotion ? 1 : 0.5)
            .opacity(shown || reduceMotion ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.55), value: shown)
            .onAppear { shown = true }
    }
}

/// Seções do quadro "Resumo do mês": previstos, para onde foi e recentes. O salário é o
/// único dado possível nesta entrega; sem ele, as seções mostram os estados vazios do
/// contrato da funcionalidade 003.
@MainActor
struct MonthSectionsView: View {
    let categoryTab: CategoryTab
    let salary: SalaryStatus?
    let hidden: Bool
    let appeared: Bool
    let send: (HomeAction) -> Void
    let confirmSalary: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var receipt: SalaryReceipt? {
        if case .received(let receipt) = salary { return receipt }
        return nil
    }

    var body: some View {
        VStack(spacing: 16) {
            forecast.modifier(HomeEnter(appeared: appeared, delay: 0.2))
            categories.modifier(HomeEnter(appeared: appeared, delay: 0.25))
            recent.modifier(HomeEnter(appeared: appeared, delay: 0.3))
        }
    }

    // MARK: Previstos

    private var forecast: some View {
        section(spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                title("Previstos para este mês")
                Spacer(minLength: 8)
                Text(forecastLabel)
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .padding(.bottom, 6)
            if let salary {
                salaryRow(salary)
            } else {
                emptyRow("Nada previsto por enquanto. Receitas e contas que se repetem aparecem aqui para você confirmar.",
                         minHeight: 60)
            }
        }
    }

    private var forecastLabel: String {
        switch salary {
        case .pending?: "1 a confirmar"
        case .received?: "tudo confirmado"
        case nil: "nada a confirmar"
        }
    }

    /// Linha do quadro: chip 38 com seta, nome, situação, valor e "Recebi" ou "Recebido".
    private func salaryRow(_ salary: SalaryStatus) -> some View {
        let received = receipt != nil
        let amount = hidden ? BRL.hidden : "+ " + BRL.format(salary.amount)
        let stacked = dynamicTypeSize.isAccessibilitySize
        let layout = stacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))
        return layout {
            HStack(spacing: 12) {
                HomeIcon(kind: .arrowUp).icon(size: 18, color: CapiaTheme.notice, lineWidth: 2)
                    .frame(width: 38, height: 38)
                    .background(CapiaTheme.selection, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Salário")
                        .font(CapiaFonts.body(15, weight: .semibold))
                    Text(received ? "Recebido neste mês" : "todo mês · previsto")
                        .font(CapiaFonts.body(13, relativeTo: .caption))
                        .foregroundStyle(CapiaTheme.muted)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Salário, \(HomeCopy.spoken(BRL.format(salary.amount), hidden: hidden)), "
                                + (received ? "recebido neste mês" : "previsto todo mês"))
            if !stacked { Spacer(minLength: 8) }
            VStack(alignment: stacked ? .leading : .trailing, spacing: 4) {
                Text(amount)
                    .font(CapiaFonts.body(15, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(CapiaTheme.notice)
                    .accessibilityHidden(true)
                if received {
                    receivedBadge
                } else {
                    Button(action: confirmSalary) {
                        Text("Recebi")
                            .font(CapiaFonts.body(13, relativeTo: .caption, weight: .bold))
                            .foregroundStyle(CapiaTheme.notice)
                            .padding(.horizontal, 12)
                            .frame(minHeight: 32)
                            .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(CapiaTheme.action, lineWidth: 1.5))
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(CapiaTapStyle())
                    .padding(.vertical, -6)
                    .accessibilityLabel("Recebi o salário")
                }
            }
        }
        .foregroundStyle(CapiaTheme.ink)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .overlay(alignment: .top) { Rectangle().fill(CapiaTheme.divider).frame(height: 1) }
    }

    private var receivedBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .heavy))
            Text("Recebido")
                .font(CapiaFonts.body(13, relativeTo: .caption, weight: .bold))
        }
        .foregroundStyle(CapiaTheme.notice)
        .padding(.horizontal, 10)
        .frame(minHeight: 32)
        .background(CapiaTheme.selection, in: RoundedRectangle(cornerRadius: 10))
        .modifier(Pop())
        .accessibilityElement(children: .combine)
    }

    // MARK: Para onde foi

    private var categories: some View {
        section(spacing: 14) {
            HStack(alignment: .center) {
                title("Para onde foi")
                Spacer(minLength: 8)
                tabs
            }
            let showsSalary = categoryTab == .income && receipt != nil
            RoundedRectangle(cornerRadius: 6)
                .fill(showsSalary ? CapiaTheme.action : CapiaTheme.divider)
                .frame(height: 12)
                .accessibilityHidden(true)
            Group {
                if showsSalary, let receipt {
                    incomeCategory(receipt)
                } else {
                    Text(categoryTab == .expenses ? "Nenhum gasto registrado neste mês."
                                                  : "Nenhuma receita registrada neste mês.")
                        .font(CapiaFonts.body(14, relativeTo: .subheadline))
                        .foregroundStyle(CapiaTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .id(categoryTab)
            .transition(.opacity)
        }
    }

    /// Linha de receita do quadro: nome, valor e barra da parte do total (aqui, 100%).
    private func incomeCategory(_ receipt: SalaryReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Salário")
                    .font(CapiaFonts.body(15))
                Spacer(minLength: 8)
                Text(HomeCopy.money(receipt.amount, hidden: hidden))
                    .font(CapiaFonts.body(15, weight: .semibold))
                    .monospacedDigit()
            }
            RoundedRectangle(cornerRadius: 3)
                .fill(CapiaTheme.action)
                .frame(height: 6)
                .accessibilityHidden(true)
        }
        .foregroundStyle(CapiaTheme.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Salário, \(HomeCopy.spoken(BRL.format(receipt.amount), hidden: hidden)), 100% das receitas")
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            tab("Gastos", .expenses)
            tab("Receitas", .income)
        }
        .padding(3)
        .background(CapiaTheme.divider, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tipo")
    }

    private func tab(_ label: String, _ value: CategoryTab) -> some View {
        let selected = categoryTab == value
        return Button { send(.selectCategory(value)) } label: {
            Text(label)
                .font(CapiaFonts.body(13, relativeTo: .caption, weight: .bold))
                .foregroundStyle(CapiaTheme.ink)
                .padding(.horizontal, 12)
                .frame(minHeight: 38)
                .background(selected ? CapiaTheme.paper : .clear, in: RoundedRectangle(cornerRadius: 9))
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.2), value: selected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    // MARK: Registros recentes

    private var recent: some View {
        section(spacing: 0) {
            title("Registros recentes")
                .padding(.bottom, 6)
            if let receipt {
                recentSalary(receipt)
            } else {
                emptyRow("Nenhum registro ainda. Use o botão + para registrar o primeiro.", minHeight: 58)
            }
        }
    }

    /// Registro do quadro: inicial em chip 38, nome, "Receita · dia/mês" e valor.
    private func recentSalary(_ receipt: SalaryReceipt) -> some View {
        let day = Self.dayMonth(receipt.confirmedAt)
        let amount = hidden ? BRL.hidden : "+ " + BRL.format(receipt.amount)
        return HStack(spacing: 12) {
            Text("S")
                .font(CapiaFonts.body(15, weight: .bold))
                .foregroundStyle(CapiaTheme.notice)
                .frame(width: 38, height: 38)
                .background(CapiaTheme.selection, in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text("Salário")
                    .font(CapiaFonts.body(15, weight: .semibold))
                Text("Receita · \(day)")
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Text(amount)
                .font(CapiaFonts.body(15, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(CapiaTheme.notice)
        }
        .foregroundStyle(CapiaTheme.ink)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .overlay(alignment: .top) { Rectangle().fill(CapiaTheme.divider).frame(height: 1) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Salário, receita de \(day), \(HomeCopy.spoken(BRL.format(receipt.amount), hidden: hidden))")
    }

    /// `05/11`, no fuso do aparelho, sem depender do idioma.
    private static func dayMonth(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let parts = calendar.dateComponents([.day, .month], from: date)
        let day = parts.day ?? 1, month = parts.month ?? 1
        return (day < 10 ? "0" : "") + "\(day)/" + (month < 10 ? "0" : "") + "\(month)"
    }

    // MARK: Componentes

    private func section<Content: View>(spacing: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: spacing, content: content)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 24))
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
            .foregroundStyle(CapiaTheme.ink)
            .accessibilityAddTraits(.isHeader)
    }

    /// Linha vazia com a divisória superior das linhas do quadro.
    private func emptyRow(_ text: String, minHeight: CGFloat) -> some View {
        Text(text)
            .font(CapiaFonts.body(14, relativeTo: .subheadline))
            .lineSpacing(2)
            .foregroundStyle(CapiaTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .overlay(alignment: .top) {
                Rectangle().fill(CapiaTheme.divider).frame(height: 1)
            }
    }
}

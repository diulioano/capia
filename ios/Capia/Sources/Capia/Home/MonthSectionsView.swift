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
    let expenses: [CategoryShare]
    let incomes: [IncomeShare]
    let recentItems: [RecentItem]
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
            let showsIncomes = categoryTab == .income && !incomes.isEmpty
            let showsExpenses = categoryTab == .expenses && !expenses.isEmpty
            if showsExpenses {
                distribution(expenses.map { (CapiaTheme.category($0.category), $0.amount) })
            } else if showsIncomes {
                distribution(incomes.indices.map { (CapiaTheme.income(at: $0), incomes[$0].amount) })
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(CapiaTheme.divider)
                    .frame(height: 12)
                    .accessibilityHidden(true)
            }
            Group {
                if showsExpenses {
                    VStack(spacing: 12) {
                        ForEach(expenses, id: \.category) { expenseCategory($0) }
                    }
                } else if showsIncomes {
                    VStack(spacing: 12) {
                        ForEach(incomes.indices, id: \.self) { incomeCategory(incomes[$0], color: CapiaTheme.income(at: $0)) }
                    }
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

    /// Barra de distribuição do quadro: segmentos proporcionais, separados por 2 pt.
    private func distribution(_ parts: [(color: Color, amount: Cents)]) -> some View {
        GeometryReader { geometry in
            let total = parts.reduce(Int64(0)) { $0 + $1.amount.value }
            let gaps = CGFloat(max(parts.count - 1, 0)) * 2
            HStack(spacing: 2) {
                ForEach(parts.indices, id: \.self) { index in
                    Rectangle()
                        .fill(parts[index].color)
                        .frame(width: total > 0
                               ? max(0, (geometry.size.width - gaps) * CGFloat(parts[index].amount.value) / CGFloat(total))
                               : 0)
                }
            }
        }
        .frame(height: 12)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .accessibilityHidden(true)
    }

    /// Linha de categoria do quadro: ponto, nome, valor · percentual e barra da parte.
    private func expenseCategory(_ share: CategoryShare) -> some View {
        let color = CapiaTheme.category(share.category)
        let amount = HomeCopy.money(share.amount, hidden: hidden)
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 4).fill(color).frame(width: 10, height: 10)
                Text(share.category.name)
                    .font(CapiaFonts.body(15))
                Spacer(minLength: 8)
                Text("\(Text(amount).font(CapiaFonts.body(15, weight: .semibold))) \(Text("· \(share.percent)%").foregroundStyle(CapiaTheme.muted))")
                    .font(CapiaFonts.body(15))
                    .monospacedDigit()
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(CapiaTheme.divider)
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: geometry.size.width * CGFloat(min(share.percent, 100)) / 100)
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)
        }
        .foregroundStyle(CapiaTheme.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(share.category.name), \(HomeCopy.spoken(BRL.format(share.amount), hidden: hidden)), "
                            + "\(share.percent)% dos gastos")
    }

    /// Linha de receita do quadro: nome, valor e barra da parte do total.
    private func incomeCategory(_ share: IncomeShare, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(share.name)
                    .font(CapiaFonts.body(15))
                    .lineLimit(2)
                Spacer(minLength: 8)
                Text(HomeCopy.money(share.amount, hidden: hidden))
                    .font(CapiaFonts.body(15, weight: .semibold))
                    .monospacedDigit()
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(CapiaTheme.divider)
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: geometry.size.width * CGFloat(min(share.percent, 100)) / 100)
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)
        }
        .foregroundStyle(CapiaTheme.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(share.name), \(HomeCopy.spoken(BRL.format(share.amount), hidden: hidden)), "
                            + "\(share.percent)% das receitas")
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
            if recentItems.isEmpty {
                emptyRow("Nenhum registro ainda. Use o botão + para registrar o primeiro.", minHeight: 58)
            } else {
                ForEach(recentItems) { recentRow($0) }
            }
        }
    }

    /// Registro do quadro: inicial em chip 38, nome, subtítulo e valor com sinal.
    private func recentRow(_ item: RecentItem) -> some View {
        let income = item.kind == .income
        let chip = RecentChip(item)
        let sign = income ? "+ " : "\u{2212} "
        let amount = hidden ? BRL.hidden : sign + BRL.format(item.amount)
        let subtitle = Self.subtitle(item)
        return HStack(spacing: 12) {
            Text(String(item.name.prefix(1)).uppercased())
                .font(CapiaFonts.body(15, weight: .bold))
                .foregroundStyle(chip.ink)
                .frame(width: 38, height: 38)
                .background(chip.fill, in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(CapiaFonts.body(15, weight: .semibold))
                    .lineLimit(2)
                Text(subtitle)
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Text(amount)
                .font(CapiaFonts.body(15, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(income ? CapiaTheme.notice : CapiaTheme.ink)
        }
        .foregroundStyle(CapiaTheme.ink)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .overlay(alignment: .top) { Rectangle().fill(CapiaTheme.divider).frame(height: 1) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.name), \(income ? "receita" : "gasto"), \(subtitle), "
                            + HomeCopy.spoken(BRL.format(item.amount), hidden: hidden))
    }

    /// `Mercado · Conta Aurora · 05/11`, `Cartão Aurora · 3× · 04/11` ou `Receita · 05/11`.
    private static func subtitle(_ item: RecentItem) -> String {
        var parts: [String] = []
        if let category = item.category { parts.append(category.name) }
        if item.isSalary { parts.append("Receita") }
        if let source = item.sourceName { parts.append(source) }
        if item.installments > 1 { parts.append("\(item.installments)×") }
        parts.append(item.day.dayMonthText)
        return parts.joined(separator: " · ")
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

/// Cores da inicial dos registros: as do quadro para receita, Mercado, Restaurantes e Saúde;
/// as demais seguem a cor da categoria em fundo claro (complemento da 004).
private struct RecentChip {
    let fill: Color
    let ink: Color

    init(_ item: RecentItem) {
        guard item.kind == .expense, let category = item.category else {
            fill = CapiaTheme.selection
            ink = CapiaTheme.notice
            return
        }
        switch category {
        case .market: fill = CapiaTheme.selection; ink = CapiaTheme.action
        case .restaurants: fill = CapiaTheme.expenseChip; ink = CapiaTheme.alert
        case .health, .other: fill = CapiaTheme.divider; ink = CapiaTheme.secondary
        case .transport: fill = Color(hex: 0xF3E7C9); ink = Color(hex: 0x6E5517)
        case .home: fill = Color(hex: 0xE1EFEA); ink = Color(hex: 0x3B6B5E)
        case .leisure: fill = Color(hex: 0xF8E8CC); ink = Color(hex: 0x7A5212)
        case .shopping: fill = Color(hex: 0xF3E4EB); ink = Color(hex: 0x7A4560)
        }
    }
}

import CapiaFlow
import SwiftUI

/// Aba Início: cabeçalho, cartão do saldo, indicadores, capivara e seções do quadro "Resumo do mês".
@MainActor
struct MonthView: View {
    let summary: MonthSummary
    let home: HomeFlow
    let send: (HomeAction) -> Void
    let confirmSalary: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var titleFocused: Bool
    @State private var appeared = false
    /// Depois do "Recebi", a capivara responde e fica feliz por 2,2 s, como no quadro.
    @State private var justReceived = false
    @State private var happy = false

    private var hidden: Bool { home.valuesHidden }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header.modifier(HomeEnter(appeared: appeared, delay: 0))
                BalanceCardView(totals: summary.totals, accountsTotal: summary.accountsTotal, hidden: hidden)
                    .modifier(HomeEnter(appeared: appeared, delay: 0.05))
                indicators.modifier(HomeEnter(appeared: appeared, delay: 0.1))
                capybara
                    .padding(.top, -4)
                    .padding(.bottom, -6)
                    .modifier(HomeEnter(appeared: appeared, delay: 0.15))
                MonthSectionsView(categoryTab: home.categoryTab, salary: summary.salary, hidden: hidden,
                                  appeared: appeared, send: send, confirmSalary: receiveSalary)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 100) // espaço para o botão +, como os 130 pt do quadro
        }
        .scrollIndicators(.hidden)
        .background(CapiaTheme.cream.ignoresSafeArea())
        .onAppear { appeared = true }
        .task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            titleFocused = true
        }
    }

    private func receiveSalary() {
        confirmSalary()
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
            justReceived = true
            happy = true
        }
        AccessibilityNotification.Announcement(HomeCopy.salaryReceivedMessage).post()
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            happy = false
        }
    }

    // MARK: Cabeçalho

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(HomeCopy.greeting(summary.calendar.greeting))
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
                Text(summary.calendar.monthName)
                    .font(CapiaFonts.title(30))
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($titleFocused)
            Spacer(minLength: 8)
            hideButton
        }
        .padding(.horizontal, 4)
    }

    /// Olho do quadro: alterna entre ocultar e mostrar todos os valores do Início.
    private var hideButton: some View {
        Button { send(.toggleValuesHidden) } label: {
            Image(systemName: hidden ? "eye.slash" : "eye")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(CapiaTheme.ink)
                .frame(width: 44, height: 44)
                .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(CapiaTapStyle())
        .accessibilityLabel(hidden ? "Mostrar valores" : "Ocultar valores")
        .accessibilityValue(hidden ? "Valores ocultos" : "Valores visíveis")
    }

    // MARK: Indicadores

    private var indicators: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 10))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 10))
        return layout {
            indicator(icon: HomeIcon(kind: .arrowUp).icon(size: 14, color: CapiaTheme.action, lineWidth: 2.6),
                      title: "Receitas",
                      value: HomeCopy.money(summary.totals.income, hidden: hidden))
            indicator(icon: HomeIcon(kind: .arrowDown).icon(size: 14, color: CapiaTheme.alert, lineWidth: 2.6),
                      title: "Gastos",
                      value: HomeCopy.money(summary.totals.expenses, hidden: hidden))
            Button { send(.openBill) } label: {
                indicator(icon: HomeIcon(kind: .card).icon(size: 14, color: CapiaTheme.secondary, lineWidth: 2.2),
                          title: "Fatura",
                          value: summary.hasCard ? HomeCopy.money(summary.totals.bill, hidden: hidden) : HomeCopy.noCard)
            }
            .buttonStyle(CapiaTapStyle())
            .accessibilityHint("Abre contas e cartões")
        }
    }

    private func indicator(icon: some View, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                icon
                Text(title)
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .foregroundStyle(CapiaTheme.secondary)
            }
            Text(value)
                .font(CapiaFonts.body(15, relativeTo: .body, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(CapiaTheme.ink)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                .minimumScaleFactor(0.75)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value == BRL.hidden ? "valor oculto" : value)")
    }

    // MARK: Capivara

    private var capybara: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Image(uiImage: happy ? CapiaImages.happyCapybara : CapiaImages.calmCapybara)
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .accessibilityHidden(true)
            Text(justReceived ? HomeCopy.salaryReceivedMessage
                              : HomeCopy.capybaraMessage(firstName: summary.firstName, salary: summary.salary))
                .id(justReceived)
                .transition(.opacity)
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .lineSpacing(3)
                .foregroundStyle(CapiaTheme.tipText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(CapiaTheme.paper,
                            in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4,
                                                       bottomTrailingRadius: 16, topTrailingRadius: 16))
                .shadow(color: CapiaTheme.shadow.opacity(0.07), radius: 7, y: 4)
                .padding(.bottom, 18)
            Spacer(minLength: 0)
        }
    }
}

/// Entrada do quadro: sobe 14 pt e aparece em 0,45 s, com atraso por bloco.
struct HomeEnter: ViewModifier {
    let appeared: Bool
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared || reduceMotion ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 14)
            .animation(reduceMotion ? nil : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.45).delay(delay),
                       value: appeared)
    }
}

import CapiaFlow
import SwiftUI

/// Formulário "Só alguns detalhes" do quadro: capivara, valor, descrição, categoria,
/// conta, data e a barra Voltar/Salvar.
@MainActor
struct RecordFormView: View {
    let flow: RecordFlow
    let send: (RecordAction) -> Void
    let save: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var descriptionFocused: Bool
    /// Folha de "Outra data", na altura do calendário.
    @State private var showingCalendar = false

    private var draft: RecordDraft { flow.draft }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                top
                amount
                description
                if draft.kind == .expense { categories }
                sources
                if flow.showsInstallments, let card = flow.selectedCard {
                    installments(card)
                        .transition(reduceMotion ? .identity : .opacity)
                }
                date
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) { actions }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: flow.showsInstallments)
        .sheet(isPresented: $showingCalendar) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Outra data")
                        .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
                        .foregroundStyle(CapiaTheme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    // Fecha a folha quando a escolha não foi um toque num dia (mês e ano na roda).
                    Button("Pronto") { showingCalendar = false }
                        .font(CapiaFonts.body(16, relativeTo: .body, weight: .bold))
                        .foregroundStyle(CapiaTheme.action)
                        .frame(minHeight: 44)
                }
                .padding(.horizontal, 8)
                DatePicker("Data do registro", selection: calendarSelection, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(CapiaTheme.action)
                    .environment(\.locale, Locale(identifier: "pt_BR"))
            }
            .padding(.horizontal, 14)
            .padding(.top, 22)
            .frame(maxHeight: .infinity, alignment: .top)
            // Sobe só até a altura do calendário; com texto ampliado, pode ir à tela cheia.
            .presentationDetents([.height(450), .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .presentationBackground(CapiaTheme.cream)
            .preferredColorScheme(.light)
        }
    }

    // MARK: Topo

    private var top: some View {
        HStack(spacing: 10) {
            Image(uiImage: flow.canSave ? CapiaImages.happyCapybara : CapiaImages.thinkingCapybara)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Só alguns detalhes")
                    .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
                Text(RecordCopy.formSubtitle(draft.kind))
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.muted)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Valor e descrição

    private var amount: some View {
        VStack(spacing: 2) {
            Text("Valor")
                .font(CapiaFonts.body(14, relativeTo: .subheadline))
                .foregroundStyle(CapiaTheme.muted)
            CentsField(value: draft.amount, accessibilityLabel: "Valor", maxValue: Record.maxAmount,
                       fontSize: 46, focusOnAppear: false) { send(.setAmount($0)) }
                .frame(maxWidth: .infinity, minHeight: 66)
            if draft.amount == .zero {
                Text("Informe um valor maior que zero.")
                    .font(CapiaFonts.body(14, relativeTo: .subheadline))
                    .foregroundStyle(CapiaTheme.alert)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Descrição")
            TextField("", text: .init(get: { draft.description }, set: { send(.setDescription($0)) }),
                      prompt: Text("Ex.: mercado, café, farmácia").foregroundStyle(CapiaTheme.placeholder))
                .font(CapiaFonts.title(22))
                .focused($descriptionFocused)
                .submitLabel(.done)
                .textInputAutocapitalization(.sentences)
                .padding(.bottom, 4)
                .frame(minHeight: 48)
                .capiaUnderline(focused: descriptionFocused)
                .accessibilityLabel("Descrição")
        }
    }

    // MARK: Categoria

    private var categories: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Categoria")
            FlowLayout(spacing: 8) {
                ForEach(RecordCategory.allCases, id: \.self) { category in
                    let selected = flow.effectiveCategory == category
                    let suggested = flow.suggestedCategory == category
                    Button { send(.chooseCategory(category)) } label: {
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(CapiaTheme.category(category))
                                .frame(width: 8, height: 8)
                            Text(category.name)
                            if suggested {
                                Text("· sugerido")
                                    .font(CapiaFonts.body(11, relativeTo: .caption2, weight: .bold))
                                    .foregroundStyle(CapiaTheme.errorText)
                            }
                        }
                        .modifier(ChipLabel(selected: selected, height: 40, radius: 20))
                    }
                    .buttonStyle(CapiaTapStyle())
                    .accessibilityLabel(category.name + (suggested ? ", sugerido" : ""))
                    .accessibilityAddTraits(selected ? [.isSelected] : [])
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: Conta

    private var sources: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(RecordCopy.sourceLabel(draft.kind))
            FlowLayout(spacing: 8) {
                ForEach(flow.availableSources, id: \.self) { source in
                    let selected = draft.source == source
                    Button { send(.chooseSource(source)) } label: {
                        Text(RecordCopy.sourceName(source, accounts: flow.accounts, cards: flow.cards))
                            .modifier(ChipLabel(selected: selected, height: 44, radius: 14))
                    }
                    .buttonStyle(CapiaTapStyle())
                    .accessibilityAddTraits(selected ? [.isSelected] : [])
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: Parcelas

    /// Bloco do quadro: "Parcelas", texto da fatura e botões − e +, de 1× a 12×.
    private func installments(_ card: CreditCard) -> some View {
        let count = draft.installments
        let text = RecordCopy.installmentsText(card: card, amount: draft.amount, count: count,
                                               purchase: RecordCopy.day(for: draft.date))
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Parcelas")
                    .font(CapiaFonts.body(16, relativeTo: .body, weight: .bold))
                Text(text)
                    .font(CapiaFonts.body(13, relativeTo: .caption))
                    .monospacedDigit()
                    .foregroundStyle(CapiaTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 8)
            HStack(spacing: 8) {
                stepButton("−", label: "Menos parcelas", step: -1,
                           enabled: count > Record.installmentRange.lowerBound)
                Text("\(count)×")
                    .font(CapiaFonts.body(18, relativeTo: .headline, weight: .bold))
                    .monospacedDigit()
                    .frame(minWidth: 32)
                    .accessibilityHidden(true)
                stepButton("+", label: "Mais parcelas", step: 1,
                           enabled: count < Record.installmentRange.upperBound)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(CapiaTheme.paper, in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .contain)
    }

    private func stepButton(_ symbol: String, label: String, step: Int, enabled: Bool) -> some View {
        Button {
            send(.stepInstallments(step))
            let next = min(max(draft.installments + step, Record.installmentRange.lowerBound),
                           Record.installmentRange.upperBound)
            AccessibilityNotification.Announcement("\(next) \(next == 1 ? "parcela" : "parcelas")").post()
        } label: {
            Text(symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(CapiaTheme.ink)
                .frame(width: 44, height: 44)
                .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(CapiaTapStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.45)
        .accessibilityLabel(label)
        .accessibilityValue("\(draft.installments)×")
    }

    // MARK: Data

    /// Data mostrada no calendário: a escolhida ou a que "Hoje"/"Ontem" representa.
    private var calendarSelection: Binding<Date> {
        Binding {
            let day = RecordCopy.day(for: draft.date)
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = .current
            return calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day, hour: 12)) ?? Date()
        } set: { date in
            let now = Date()
            let previous = RecordCopy.day(for: draft.date)
            let day = CalendarDay(date: date, timeZone: .current)
            let today = CalendarDay.today(now: now, timeZone: .current)
            if day == today {
                send(.chooseDate(.today))
            } else if day == CalendarDay.yesterday(now: now, timeZone: .current) {
                send(.chooseDate(.yesterday))
            } else {
                send(.chooseDate(.other(day)))
            }
            if Self.isDayTap(from: previous, to: day, today: today) {
                // Tocar num dia fecha a folha.
                showingCalendar = false
                AccessibilityNotification.Announcement("Data escolhida: \(day.dayMonthText)").post()
            }
        }
    }

    /// Distingue o toque num dia da roda de mês e ano, que também muda a data mas mantém o
    /// dia (ou o ajusta ao fim do mês ou a hoje). Nesses casos a folha fica aberta.
    private static func isDayTap(from previous: CalendarDay, to day: CalendarDay, today: CalendarDay) -> Bool {
        guard day != previous else { return false }
        if day.yearMonth == previous.yearMonth { return true }
        if day.day == previous.day { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let start = calendar.date(from: DateComponents(year: day.year, month: day.month, day: 1)) ?? Date()
        let lastDay = calendar.range(of: .day, in: .month, for: start)?.count ?? 31
        let clampedToMonthEnd = day.day == lastDay && previous.day > lastDay
        let clampedToToday = day == today
        return !(clampedToMonthEnd || clampedToToday)
    }

    private var date: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Data")
            FlowLayout(spacing: 8) {
                dateChip("Hoje", selected: draft.date == .today) { send(.chooseDate(.today)) }
                dateChip("Ontem", selected: draft.date == .yesterday) { send(.chooseDate(.yesterday)) }
                if case .other(let day) = draft.date {
                    dateChip(day.dayMonthText, selected: true, hint: "Escolher outra data") { showingCalendar = true }
                } else {
                    dateChip("Outra data", selected: false) { showingCalendar = true }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func dateChip(_ label: String, selected: Bool, hint: String? = nil,
                          action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).modifier(ChipLabel(selected: selected, height: 44, radius: 14, horizontal: 16))
        }
        .buttonStyle(CapiaTapStyle())
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        .accessibilityHint(hint ?? "")
    }

    // MARK: Ações

    private var actions: some View {
        HStack(spacing: 10) {
            Button { send(.back) } label: {
                Text("Voltar")
                    .font(CapiaFonts.body(16, relativeTo: .headline, weight: .bold))
                    .foregroundStyle(CapiaTheme.ink)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 56)
                    .background(CapiaTheme.sand, in: RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(CapiaTapStyle())
            Button("Salvar", action: save)
                .buttonStyle(SaveButtonStyle())
                .disabled(!flow.canSave)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background {
            CapiaTheme.cream
                .overlay(alignment: .top) { Rectangle().fill(CapiaTheme.track).frame(height: 1) }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .bold))
            .foregroundStyle(CapiaTheme.tipText)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Ficha do quadro: creme com borda areia; selecionada, verde claro com borda verde.
private struct ChipLabel: ViewModifier {
    let selected: Bool
    let height: CGFloat
    let radius: CGFloat
    var horizontal: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .font(CapiaFonts.body(14, relativeTo: .subheadline, weight: .semibold))
            .foregroundStyle(CapiaTheme.ink)
            .padding(.horizontal, horizontal)
            .frame(minHeight: height)
            .capiaOption(selected: selected, cornerRadius: radius)
            .contentShape(Rectangle())
    }
}

/// Salvar: como Continuar, com 56 pt e raio 18.
private struct SaveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CapiaFonts.body(17, relativeTo: .headline, weight: .bold))
            .foregroundStyle(isEnabled ? CapiaTheme.actionText : CapiaTheme.muted)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(isEnabled ? CapiaTheme.action : CapiaTheme.inactive, in: RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}

/// Fichas que quebram linha, como o `flex-wrap` do quadro.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews, width: proposal.width ?? .infinity)
        let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews, width: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.init(width: bounds.width, height: nil))
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .init(width: min(size.width, bounds.width),
                                                                                height: size.height))
                x += min(size.width, bounds.width) + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.init(width: width, height: nil))
            let itemWidth = min(size.width, width)
            if !current.indices.isEmpty, current.width + spacing + itemWidth > width {
                rows.append(current)
                current = Row()
            }
            current.width += (current.indices.isEmpty ? 0 : spacing) + itemWidth
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty { rows.append(current) }
        return rows
    }
}

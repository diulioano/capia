import CapiaFlow
import SwiftUI

/// Novo registro sobre o Início. Esqueleto provisório da base: texto e botões simples
/// ligados a `RecordFlow`. As telas finais do quadro chegam nas US.
@MainActor
struct NewRecordView: View {
    let flow: RecordFlow
    let send: (RecordAction) -> Void
    let save: () -> Void
    let undo: () -> Void
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(RecordCopy.closeLabel, action: close)
                Spacer()
            }
            Text(RecordCopy.title(flow)).font(CapiaFonts.title(20)).accessibilityAddTraits(.isHeader)
            Picker("Forma de registro", selection: .init(get: { flow.mode }, set: { send(.selectMode($0)) })) {
                ForEach(RecordMode.allCases, id: \.self) { Text(RecordCopy.modeLabel($0)).tag($0) }
            }
            .pickerStyle(.segmented)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if flow.mode != .type {
                        Text(RecordCopy.modePlaceholder(flow.mode))
                    } else if flow.phase == .amount {
                        amount
                    } else {
                        details
                    }
                    if flow.saveFailed {
                        Text(RecordCopy.saveFailed)
                        Button(RecordCopy.retry, action: save)
                    }
                    if let toast = flow.toast {
                        Text("\(RecordCopy.saved) · \(RecordCopy.toastSubtitle(toast.record, accounts: flow.accounts, cards: flow.cards))")
                        Button(RecordCopy.undo, action: undo)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CapiaTheme.cream.ignoresSafeArea())
    }

    private var amount: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ForEach(RecordKind.allCases, id: \.self) { kind in
                    Button(RecordCopy.kindLabel(kind)) { send(.selectKind(kind)) }
                        .bold(flow.draft.kind == kind)
                }
            }
            Text(RecordCopy.padHint(flow.draft.kind))
            Text(BRL.format(flow.draft.amount)).font(CapiaFonts.title(40)).monospacedDigit()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(1...9, id: \.self) { digit in key("\(digit)", .digit(digit)) }
                key("00", .doubleZero)
                key("0", .digit(0))
                key("⌫", .delete)
            }
            Button("Continuar") { send(.continueToDetails) }.disabled(!flow.canContinue)
        }
    }

    private func key(_ label: String, _ key: PadKey) -> some View {
        Button(label) { send(.press(key)) }.frame(maxWidth: .infinity, minHeight: 44)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            CentsField(value: flow.draft.amount, accessibilityLabel: "Valor", maxValue: Record.maxAmount,
                       fontSize: 32, focusOnAppear: false) { send(.setAmount($0)) }
                .frame(height: 50)
            TextField("Ex.: mercado, café, farmácia",
                      text: .init(get: { flow.draft.description }, set: { send(.setDescription($0)) }))
            if flow.draft.kind == .expense {
                Text("Categoria")
                ForEach(RecordCategory.allCases, id: \.self) { category in
                    Button(category.name + (flow.suggestedCategory == category ? " · sugerido" : "")) {
                        send(.chooseCategory(category))
                    }
                    .bold(flow.effectiveCategory == category)
                }
            }
            Text(RecordCopy.sourceLabel(flow.draft.kind))
            ForEach(flow.availableSources, id: \.self) { source in
                Button(RecordCopy.sourceName(source, accounts: flow.accounts, cards: flow.cards)) {
                    send(.chooseSource(source))
                }
                .bold(flow.draft.source == source)
            }
            if flow.showsInstallments, let card = flow.selectedCard {
                Stepper("Parcelas: \(flow.draft.installments)×",
                        onIncrement: { send(.stepInstallments(1)) },
                        onDecrement: { send(.stepInstallments(-1)) })
                Text(RecordCopy.installmentsText(card: card, amount: flow.draft.amount, count: flow.draft.installments,
                                                 purchase: RecordCopy.day(for: flow.draft.date)))
            }
            HStack {
                Button("Hoje") { send(.chooseDate(.today)) }.bold(flow.draft.date == .today)
                Button("Ontem") { send(.chooseDate(.yesterday)) }.bold(flow.draft.date == .yesterday)
            }
            HStack {
                Button("Voltar") { send(.back) }
                Button("Salvar", action: save).disabled(!flow.canSave)
            }
        }
    }
}

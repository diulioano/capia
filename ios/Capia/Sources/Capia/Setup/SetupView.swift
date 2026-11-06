import CapiaFlow
import SwiftUI

/// Configuração inicial. Esqueleto provisório da base: cada etapa usa controles simples
/// até a US dona da tela substituí-la pela versão fiel ao quadro "Configuração inicial".
@MainActor
struct SetupView: View {
    let flow: SetupFlow
    let saveFailed: Bool
    let edit: ((inout SetupDraft) -> Void) -> Void
    let send: (SetupAction) -> Void
    let retrySave: () -> Void

    var body: some View {
        // Capture the rendered step, rather than reading the latest state in a tap.
        let source = flow.step
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if flow.canGoBack {
                    Button("Voltar") { send(.init(.back, from: source)) }
                        .frame(minWidth: 44, minHeight: 44)
                }
                Spacer()
                if let position = source.position {
                    Text("Etapa \(position) de \(SetupStep.count)")
                        .font(CapiaFonts.body(14))
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ProvisionalStepContent(flow: flow, saveFailed: saveFailed, edit: edit,
                                           send: { send(.init($0, from: source)) },
                                           retrySave: retrySave)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if source != .done {
                Button("Continuar") { send(.init(.continueStep, from: source)) }
                    .buttonStyle(CapiaPrimaryButtonStyle())
                    .disabled(!flow.canContinue)
                    .opacity(flow.canContinue ? 1 : 0.4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
        .background(CapiaTheme.cream.ignoresSafeArea())
        .id(source)
    }
}

/// Conteúdo provisório das etapas. Substituído por arquivo próprio em cada US.
@MainActor
private struct ProvisionalStepContent: View {
    let flow: SetupFlow
    let saveFailed: Bool
    let edit: ((inout SetupDraft) -> Void) -> Void
    let send: (SetupAction.Intent) -> Void
    let retrySave: () -> Void

    private var draft: SetupDraft { flow.draft }

    private func binding<Value>(_ keyPath: WritableKeyPath<SetupDraft, Value>) -> Binding<Value> {
        Binding(get: { draft[keyPath: keyPath] },
                set: { value in edit { $0[keyPath: keyPath] = value } })
    }

    var body: some View {
        switch flow.step {
        case .name:
            Text("Como podemos te chamar?").font(CapiaFonts.title(28))
            TextField("Nome ou apelido", text: binding(\.name))
            if draft.isNameOneShort { Text("Só mais uma letrinha.") }
        case .goals:
            Text("\(draft.greeting), o que te trouxe aqui?").font(CapiaFonts.title(28))
            ForEach(SetupGoal.allCases, id: \.self) { goal in
                Button("\(draft.goals.contains(goal) ? "☑" : "☐") \(goal.rawValue)") {
                    edit { $0.toggle(goal) }
                }
            }
        case .account:
            Text("Vamos cadastrar sua primeira conta").font(CapiaFonts.title(28))
            Picker("Tipo", selection: binding(\.accountKind)) {
                ForEach(AccountKind.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            TextField("Nome do banco ou apelido", text: binding(\.accountName))
        case .balance:
            Text("Quanto tem hoje em \(draft.accountDisplayName)?").font(CapiaFonts.title(28))
            TextField("Saldo inicial", text: Binding(
                get: { BRL.format(draft.balance) },
                set: { text in edit { $0.balance = Cents(typed: text) } }))
                .keyboardType(.numberPad)
            HStack {
                ForEach(SetupDraft.balanceShortcutsInReais, id: \.self) { reais in
                    Button(BRL.shortcutLabel(reais: reais)) { edit { $0.addToBalance(reais: reais) } }
                }
            }
        case .cardQuestion:
            Text("Você usa cartão de crédito de \(draft.accountDisplayName)?").font(CapiaFonts.title(28))
            Button("\(draft.hasCard == true ? "●" : "○") Sim, tenho cartão") { edit { $0.hasCard = true } }
            Button("\(draft.hasCard == false ? "●" : "○") Agora não") { edit { $0.hasCard = false } }
        case .cardDates:
            Text("Datas do cartão \(draft.accountDisplayName)").font(CapiaFonts.title(26))
            Stepper("Fecha no dia \(draft.closingDay)",
                    value: Binding(get: { draft.closingDay }, set: { day in edit { $0.setClosingDay(day) } }),
                    in: CreditCard.days)
            Stepper("Vence no dia \(draft.dueDay)",
                    value: Binding(get: { draft.dueDay }, set: { day in edit { $0.setDueDay(day) } }),
                    in: CreditCard.days)
            if !draft.areCardDaysValid { Text("Fechamento e vencimento precisam ser em dias diferentes.") }
        case .done:
            Text("Tudo pronto, \(draft.greeting)!").font(CapiaFonts.title(30))
            ForEach(flow.accounts) { account in
                Text("\(account.name) · \(account.kind.rawValue) · \(BRL.format(account.initialBalance))")
            }
            ForEach(flow.cards) { card in
                Text("Cartão \(card.name) · Fecha dia \(card.closingDay) · vence dia \(card.dueDay) · Separado")
            }
            if flow.cards.isEmpty { Text("Sem cartão por enquanto.") }
            if saveFailed {
                Text("Não consegui guardar no aparelho. Seus dados ficam só até fechar o app.")
                Button("Tentar de novo", action: retrySave)
            }
            Button("Ver meu mês") { send(.viewMonth) }
                .buttonStyle(CapiaPrimaryButtonStyle())
            Button("Adicionar outra conta") { send(.addAnotherAccount) }
                .frame(minHeight: 44)
        }
    }
}

import Foundation

/// Etapas da configuração inicial, na ordem do quadro "Configuração inicial". O salário
/// mensal é um complemento ao design (funcionalidade 003, US5), depois do saldo.
public enum SetupStep: Int, CaseIterable, Sendable {
    case name, goals, account, balance, salary, cardQuestion, cardDates, done

    public static let count = 7

    /// Posição de 1 a 7 na barra de progresso. A conclusão não tem posição.
    public var position: Int? { self == .done ? nil : rawValue + 1 }
}

/// Define para onde Voltar leva nas pontas do fluxo.
public enum SetupMode: Equatable, Sendable {
    /// Primeira configuração, aberta a partir de uma etapa da apresentação.
    case firstRun(origin: IntroStep)
    /// Nova conta a partir da conclusão; nome e objetivos não são revisitados.
    case addingAccount
}

public enum SetupMood: Equatable, Sendable {
    case calm, thinking, happy, celebrating
}

/// Saídas do fluxo de configuração, tratadas pela raiz do app.
public enum SetupExit: Equatable, Sendable {
    case introduction(IntroStep)
    case month
}

/// Valores parciais preservados ao voltar entre etapas.
public struct SetupDraft: Equatable, Sendable {
    public static let defaultClosingDay = 3
    public static let defaultDueDay = 10
    public static let balanceShortcutsInReais: [Int64] = [500, 1_000, 2_500]

    public var name = ""
    public var goals: Set<SetupGoal> = []
    public var accountKind = AccountKind.checking
    public var accountName = ""
    public var balance = Cents.zero
    /// Salário mensal; zero significa que a pessoa não informou.
    public var salary = Cents.zero
    public var hasCard: Bool?
    public var closingDay = SetupDraft.defaultClosingDay
    public var dueDay = SetupDraft.defaultDueDay
    /// Depois que a pessoa escolhe o vencimento, mudar o fechamento não o sugere mais.
    public private(set) var dueDayChosen = false

    public init() {}

    public var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    public var trimmedAccountName: String { accountName.trimmingCharacters(in: .whitespacesAndNewlines) }

    public var isNameValid: Bool { trimmedName.count >= 2 }
    /// Uma única letra mostra "Só mais uma letrinha.".
    public var isNameOneShort: Bool { trimmedName.count == 1 }
    public var isAccountValid: Bool { accountKind == .wallet || trimmedAccountName.count >= 2 }
    public var areCardDaysValid: Bool { closingDay != dueDay }
    /// Aviso não bloqueante quando a distância foge da faixa usual dos bancos.
    public var isCardGapUnusual: Bool {
        areCardDaysValid && !CreditCard.typicalGap.contains(CreditCard.gap(closingDay: closingDay, dueDay: dueDay))
    }
    public var dueIsNextMonth: Bool { CreditCard.dueIsNextMonth(closingDay: closingDay, dueDay: dueDay) }

    /// Nome exibido da conta: aparado; Carteira sem apelido vira "Carteira".
    public var accountDisplayName: String {
        if !trimmedAccountName.isEmpty { return trimmedAccountName }
        return accountKind == .wallet ? "Carteira" : "sua conta"
    }

    /// Primeira palavra do nome aparado.
    public var greeting: String {
        trimmedName.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? ""
    }

    public mutating func toggle(_ goal: SetupGoal) {
        if goals.contains(goal) { goals.remove(goal) } else { goals.insert(goal) }
    }

    public mutating func addToBalance(reais: Int64) {
        balance = balance.adding(Cents(reais: reais))
    }

    /// Escolhe o fechamento e, enquanto a pessoa não escolheu o vencimento, sugere
    /// o vencimento sete dias depois.
    public mutating func setClosingDay(_ day: Int) {
        guard CreditCard.days.contains(day) else { return }
        closingDay = day
        if !dueDayChosen { dueDay = CreditCard.suggestedDueDay(closingDay: day) }
    }

    public mutating func setDueDay(_ day: Int) {
        guard CreditCard.days.contains(day) else { return }
        dueDay = day
        dueDayChosen = true
    }

    /// Limpa somente a conta e o cartão, preservando nome e objetivos.
    mutating func resetAccountAndCard() {
        accountKind = .checking
        accountName = ""
        balance = .zero
        hasCard = nil
        closingDay = Self.defaultClosingDay
        dueDay = Self.defaultDueDay
        dueDayChosen = false
    }
}

public struct SetupAction: Sendable {
    public enum Intent: CaseIterable, Sendable {
        case continueStep, back, addAnotherAccount, viewMonth
    }

    public let intent: Intent
    public let source: SetupStep

    public init(_ intent: Intent, from source: SetupStep) {
        self.intent = intent
        self.source = source
    }
}

/// Estado da configuração em andamento. Só existe na sessão; o espaço concluído é
/// montado por `space(completedAt:)` e guardado pela raiz do app.
public struct SetupFlow: Sendable {
    public private(set) var step: SetupStep
    public var draft: SetupDraft
    public private(set) var mode: SetupMode
    public private(set) var accounts: [Account]
    public private(set) var cards: [CreditCard]
    /// Recebimentos já confirmados no espaço restaurado, preservados ao gravar de novo.
    public private(set) var salaryReceipts: [SalaryReceipt] = []
    /// Registros do espaço, preservados ao adicionar outra conta.
    public private(set) var records: [Record] = []
    /// Itens anexados ao chegar à conclusão a partir do rascunho atual. Voltar os remove.
    private var lastAppended: (account: UUID, card: UUID?)?

    public init(origin: IntroStep) {
        step = .name
        draft = SetupDraft()
        mode = .firstRun(origin: origin)
        accounts = []
        cards = []
    }

    /// Abre a conclusão de um espaço guardado, sem rascunho para voltar.
    public init(restoring space: ConfiguredSpace) {
        step = .done
        draft = SetupDraft()
        draft.name = space.profile.name
        draft.goals = space.profile.goals
        draft.salary = space.monthlySalary ?? .zero
        salaryReceipts = space.salaryReceipts
        records = space.records
        mode = .addingAccount
        accounts = space.accounts
        cards = space.cards
    }

    public var canContinue: Bool {
        switch step {
        case .name: draft.isNameValid
        case .goals: !draft.goals.isEmpty
        case .account: draft.isAccountValid
        case .balance: true
        case .salary: true
        case .cardQuestion: draft.hasCard != nil
        case .cardDates: draft.areCardDaysValid
        case .done: false
        }
    }

    /// Voltar só existe na conclusão quando há um rascunho que a originou.
    public var canGoBack: Bool { step != .done || lastAppended != nil }

    public var mood: SetupMood {
        if step == .done { return .celebrating }
        if canContinue { return .happy }
        if step == .name && draft.trimmedName.isEmpty { return .calm }
        return .thinking
    }

    public var profile: Profile { Profile(name: draft.trimmedName, goals: draft.goals) }

    /// Espaço a guardar. Existe somente na conclusão e com pelo menos uma conta.
    public func space(completedAt date: Date) -> ConfiguredSpace? {
        guard step == .done, !accounts.isEmpty else { return nil }
        return ConfiguredSpace(profile: profile, accounts: accounts, cards: cards, completedAt: date,
                               monthlySalary: draft.salary, salaryReceipts: salaryReceipts, records: records)
    }

    /// Aplica uma ação de navegação. Ações de origem antiga, incompatíveis ou com etapa
    /// inválida não mudam o estado. Devolve uma saída quando o fluxo deve ser deixado.
    @discardableResult
    public mutating func send(_ action: SetupAction) -> SetupExit? {
        guard action.source == step else { return nil }
        switch action.intent {
        case .continueStep: continueStep()
        case .back: return back()
        case .addAnotherAccount: addAnotherAccount()
        case .viewMonth: return step == .done ? .month : nil
        }
        return nil
    }

    private mutating func continueStep() {
        guard canContinue else { return }
        switch step {
        case .name: step = .goals
        case .goals: step = .account
        case .account: step = .balance
        // O salário pertence ao perfil: "Adicionar outra conta" não o pergunta de novo.
        case .balance: step = mode == .addingAccount ? .cardQuestion : .salary
        case .salary: step = .cardQuestion
        case .cardQuestion:
            if draft.hasCard == true { step = .cardDates } else { complete() }
        case .cardDates: complete()
        case .done: break
        }
    }

    private mutating func complete() {
        let name = draft.accountDisplayName
        let account = Account(kind: draft.accountKind, name: name, initialBalance: draft.balance)
        accounts.append(account)
        var cardID: UUID?
        if draft.hasCard == true {
            let card = CreditCard(name: name, closingDay: draft.closingDay, dueDay: draft.dueDay)
            cards.append(card)
            cardID = card.id
        }
        lastAppended = (account.id, cardID)
        step = .done
    }

    private mutating func back() -> SetupExit? {
        switch step {
        case .name:
            if case .firstRun(let origin) = mode { return .introduction(origin) }
        case .goals: step = .name
        case .account:
            if mode == .addingAccount { step = .done } else { step = .goals }
        case .balance: step = .account
        case .salary: step = .balance
        case .cardQuestion: step = mode == .addingAccount ? .balance : .salary
        case .cardDates: step = .cardQuestion
        case .done:
            guard let appended = lastAppended else { return nil }
            accounts.removeAll { $0.id == appended.account }
            if let card = appended.card { cards.removeAll { $0.id == card } }
            lastAppended = nil
            step = appended.card == nil ? .cardQuestion : .cardDates
        }
        return nil
    }

    private mutating func addAnotherAccount() {
        guard step == .done else { return }
        lastAppended = nil
        draft.resetAccountAndCard()
        mode = .addingAccount
        step = .account
    }

    /// Registra o recebimento do salário de um mês, uma única vez.
    mutating func recordSalaryReceipt(_ receipt: SalaryReceipt) {
        guard !salaryReceipts.contains(where: { $0.year == receipt.year && $0.month == receipt.month }) else { return }
        salaryReceipts.append(receipt)
    }

    /// Acompanha os registros do espaço da sessão.
    mutating func replaceRecords(_ records: [Record]) {
        self.records = records
    }
}

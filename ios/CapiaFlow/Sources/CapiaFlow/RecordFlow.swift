import Foundation

/// Abas do quadro "Novo registro". Só Digitar registra nesta entrega.
public enum RecordMode: CaseIterable, Equatable, Sendable {
    case type, speak, photo
}

/// Fases de Digitar: o teclado do valor e o formulário de detalhes.
public enum RecordPhase: Equatable, Sendable {
    case amount, details
}

public enum DateChoice: Equatable, Sendable {
    case today, yesterday, other(CalendarDay)
}

/// Teclas do teclado do quadro: 1–9, 0, 00 e apagar.
public enum PadKey: Equatable, Sendable {
    case digit(Int), doubleZero, delete
}

/// Campos do registro em preenchimento. Existe só na sessão; não é o rascunho de voz ou
/// imagem do CONTEXT.md.
public struct RecordDraft: Equatable, Sendable {
    public var kind: RecordKind
    public var amount: Cents
    public var description: String
    /// Escolha explícita da pessoa; prevalece sobre a sugestão.
    public var chosenCategory: RecordCategory?
    public var source: PaymentSource?
    public var installments: Int
    public var date: DateChoice

    public init(kind: RecordKind = .expense, amount: Cents = .zero, source: PaymentSource?) {
        self.kind = kind
        self.amount = amount
        description = ""
        chosenCategory = nil
        self.source = source
        installments = 1
        date = .today
    }
}

/// Último registro salvo, com o formulário de antes, para "Desfazer".
public struct SavedToast: Equatable, Sendable {
    public let record: Record
    public let previous: RecordDraft
}

public enum RecordAction: Equatable, Sendable {
    case selectMode(RecordMode)
    case selectKind(RecordKind)
    case press(PadKey)
    case continueToDetails
    case back
    case setAmount(Cents)
    case setDescription(String)
    case chooseCategory(RecordCategory)
    case chooseSource(PaymentSource)
    case stepInstallments(Int)
    case chooseDate(DateChoice)
    case dismissToast
}

/// Estado do novo registro durante a sessão (data-model.md).
public struct RecordFlow: Equatable, Sendable {
    public private(set) var mode: RecordMode = .type
    public private(set) var phase: RecordPhase = .amount
    public private(set) var draft: RecordDraft
    public private(set) var toast: SavedToast?
    public private(set) var saveFailed = false
    public let accounts: [Account]
    public let cards: [CreditCard]

    public init(accounts: [Account], cards: [CreditCard]) {
        self.accounts = accounts
        self.cards = cards
        draft = RecordDraft(source: accounts.first.map { .account(id: $0.id) })
    }

    // MARK: Derivados

    /// Sugestão pela descrição, só enquanto a pessoa não escolheu uma categoria.
    public var suggestedCategory: RecordCategory? {
        draft.chosenCategory == nil ? RecordCategory.suggestion(for: draft.description) : nil
    }

    public var effectiveCategory: RecordCategory? { draft.chosenCategory ?? suggestedCategory }

    public var canContinue: Bool { draft.amount.value > 0 }

    public var canSave: Bool {
        guard draft.amount.value > 0, draft.source != nil else { return false }
        return draft.kind == .income || effectiveCategory != nil
    }

    /// Receita só entra em contas; gasto pode sair de contas ou cartões.
    public var availableSources: [PaymentSource] {
        let accountSources = accounts.map { PaymentSource.account(id: $0.id) }
        return draft.kind == .income ? accountSources : accountSources + cards.map { .card(id: $0.id) }
    }

    public var showsInstallments: Bool { draft.kind == .expense && draft.source?.isCard == true }

    /// Cartão escolhido, para o texto da fatura e das parcelas.
    public var selectedCard: CreditCard? {
        guard case .card(let id)? = draft.source else { return nil }
        return cards.first { $0.id == id }
    }

    // MARK: Ações

    public mutating func send(_ action: RecordAction) {
        switch action {
        case .selectMode(let mode):
            self.mode = mode
        case .selectKind(let kind):
            guard mode == .type, phase == .amount else { return }
            draft.kind = kind
            if kind == .income {
                if draft.source?.isCard == true { draft.source = accounts.first.map { .account(id: $0.id) } }
                draft.installments = 1
            }
        case .press(let key):
            guard mode == .type, phase == .amount else { return }
            draft.amount = Self.apply(key, to: draft.amount)
        case .continueToDetails:
            guard mode == .type, phase == .amount, canContinue else { return }
            phase = .details
        case .back:
            guard phase == .details else { return }
            phase = .amount
        case .setAmount(let amount):
            guard phase == .details else { return }
            draft.amount = Swift.min(amount, Record.maxAmount)
        case .setDescription(let text):
            guard phase == .details else { return }
            draft.description = String(text.prefix(Record.maxDescriptionLength))
        case .chooseCategory(let category):
            guard phase == .details, draft.kind == .expense else { return }
            draft.chosenCategory = category
        case .chooseSource(let source):
            guard phase == .details, availableSources.contains(source) else { return }
            draft.source = source
            if !source.isCard { draft.installments = 1 }
        case .stepInstallments(let step):
            guard phase == .details, showsInstallments else { return }
            let range = Record.installmentRange
            draft.installments = Swift.min(Swift.max(draft.installments + step, range.lowerBound), range.upperBound)
        case .chooseDate(let date):
            guard phase == .details else { return }
            draft.date = date
        case .dismissToast:
            toast = nil
        }
    }

    /// Teclado como num caixa: algarismos entram pela direita; o que passaria do limite é
    /// ignorado.
    static func apply(_ key: PadKey, to amount: Cents) -> Cents {
        let value: Int64
        switch key {
        case .delete: value = amount.value / 10
        case .doubleZero: value = amount.value * 100
        case .digit(let digit):
            guard (0...9).contains(digit) else { return amount }
            value = amount.value * 10 + Int64(digit)
        }
        return value > Record.maxAmount.value ? amount : Cents(value)
    }

    /// Registro a guardar, se o formulário permite salvar e a data não é futura. Não muda
    /// o estado: a raiz grava antes de confirmar com `didSave`.
    public func makeRecord(now: Date, timeZone: TimeZone, id: UUID = UUID()) -> Record? {
        guard mode == .type, phase == .details, canSave, let source = draft.source else { return nil }
        let today = CalendarDay.today(now: now, timeZone: timeZone)
        let day: CalendarDay
        switch draft.date {
        case .today: day = today
        case .yesterday: day = CalendarDay.yesterday(now: now, timeZone: timeZone)
        case .other(let chosen): day = chosen
        }
        guard day <= today else { return nil }
        let record = Record(id: id, kind: draft.kind, amount: draft.amount, description: draft.description,
                            category: draft.kind == .expense ? effectiveCategory : nil, source: source,
                            day: day, installments: showsInstallments ? draft.installments : 1, savedAt: now)
        return record.isValid ? record : nil
    }

    // MARK: Chamadas da raiz

    /// Registro guardado: mostra o aviso e volta ao teclado zerado, mantendo o tipo.
    mutating func didSave(_ record: Record) {
        toast = SavedToast(record: record, previous: draft)
        draft = RecordDraft(kind: draft.kind, source: accounts.first.map { .account(id: $0.id) })
        phase = .amount
        saveFailed = false
    }

    /// A gravação falhou: nada muda além do aviso de falha.
    mutating func saveDidFail() {
        saveFailed = true
    }

    /// "Desfazer": restaura o formulário de antes de salvar.
    mutating func undo() {
        guard let toast else { return }
        draft = toast.previous
        mode = .type
        phase = .details
        self.toast = nil
        saveFailed = false
    }
}

import Foundation

/// Tipo de registro: gasto ou receita (CONTEXT.md).
public enum RecordKind: String, CaseIterable, Codable, Hashable, Sendable {
    case expense, income
}

/// As oito categorias iniciais do quadro "Novo registro", na ordem do quadro.
public enum RecordCategory: String, CaseIterable, Codable, Hashable, Sendable {
    case market, restaurants, transport, home, leisure, health, shopping, other

    /// Nome exibido, igual em qualquer idioma do aparelho.
    public var name: String {
        switch self {
        case .market: "Mercado"
        case .restaurants: "Restaurantes"
        case .transport: "Transporte"
        case .home: "Casa"
        case .leisure: "Lazer"
        case .health: "Saúde"
        case .shopping: "Compras"
        case .other: "Outros"
        }
    }

    /// Trechos do quadro, procurados dentro de cada palavra ("supermercado" casa "mercad"),
    /// e palavras inteiras para termos curtos que casariam por acaso ("barato", "1999").
    /// A ordem decide quando mais de uma casa.
    private static let rules: [(category: RecordCategory, fragments: [String], words: [String])] = [
        (.market, ["mercad", "feira", "hortifruti", "sacol"], []),
        (.restaurants, ["caf", "restaur", "padaria", "lanche", "almo", "jantar", "pizza", "ifood"], []),
        (.transport, ["uber", "onibus", "metr", "posto", "gasolina", "combust"], ["99"]),
        (.health, ["farm", "medic", "consulta", "dentista"], []),
        (.home, ["aluguel", "agua", "internet", "condom"], ["luz"]),
        (.leisure, ["cinema", "show", "stream", "viagem", "jogo"], ["bar"]),
        (.shopping, ["loja", "roupa", "tenis", "livro"], []),
    ]

    /// Categoria sugerida pela descrição, sem diferenciar caixa nem acentos. `nil` quando
    /// nenhuma palavra corresponde. "Outros" nunca é sugerida.
    public static func suggestion(for description: String) -> RecordCategory? {
        let folded = description
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .lowercased()
        let words = folded.split { !$0.isLetter && !$0.isNumber }.map(String.init)
        guard !words.isEmpty else { return nil }
        for rule in rules {
            for word in words {
                if rule.words.contains(word) || rule.fragments.contains(where: { word.contains($0) }) {
                    return rule.category
                }
            }
        }
        return nil
    }
}

/// Onde o dinheiro saiu ou entrou: uma conta ou um cartão de crédito, que são distintos.
public enum PaymentSource: Codable, Hashable, Sendable {
    case account(id: UUID)
    case card(id: UUID)

    public var isCard: Bool {
        if case .card = self { return true }
        return false
    }
}

/// Ano e mês do calendário gregoriano.
public struct YearMonth: Hashable, Comparable, Sendable {
    public let year: Int
    public let month: Int

    public init(year: Int, month: Int) {
        let index = year * 12 + (month - 1)
        self.year = index >= 0 ? index / 12 : (index - 11) / 12
        self.month = index - self.year * 12 + 1
    }

    public func adding(months: Int) -> YearMonth {
        YearMonth(year: year, month: month + months)
    }

    /// Quantidade de dias do mês, com fevereiro bissexto.
    public var dayCount: Int {
        switch month {
        case 2:
            let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return leap ? 29 : 28
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }

    /// Nome abreviado em português, minúsculo: "jan"…"dez".
    public var shortName: String {
        ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"][month - 1]
    }

    /// Nome completo em português, minúsculo: "janeiro"…"dezembro".
    public var name: String { MonthCalendar.monthNames[month - 1].lowercased() }

    public static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }
}

/// Dia do calendário da pessoa. Um registro pertence a um dia, não a um instante, para
/// não mudar de dia nem de mês ao trocar o fuso.
public struct CalendarDay: Hashable, Comparable, Codable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Dia de um instante no fuso indicado, pelo calendário gregoriano.
    public init(date: Date, timeZone: TimeZone) {
        let parts = Self.calendar(timeZone).dateComponents([.year, .month, .day], from: date)
        self.init(year: parts.year ?? 0, month: parts.month ?? 1, day: parts.day ?? 1)
    }

    public static func today(now: Date, timeZone: TimeZone) -> CalendarDay {
        CalendarDay(date: now, timeZone: timeZone)
    }

    public static func yesterday(now: Date, timeZone: TimeZone) -> CalendarDay {
        let calendar = calendar(timeZone)
        let start = calendar.startOfDay(for: now)
        let previous = calendar.date(byAdding: .day, value: -1, to: start) ?? start
        return CalendarDay(date: previous, timeZone: timeZone)
    }

    public var yearMonth: YearMonth { YearMonth(year: year, month: month) }

    /// `dd/mm`, como nos registros do quadro.
    public var dayMonthText: String {
        String(format: "%02d/%02d", day, month)
    }

    public static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    private static func calendar(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}

/// Gasto ou receita confirmado pela pessoa e guardado no espaço.
public struct Record: Codable, Equatable, Identifiable, Sendable {
    /// R$ 999.999,99, o limite do teclado do quadro.
    public static let maxAmount = Cents(99_999_999)
    public static let maxAmountDigits = 8
    public static let maxDescriptionLength = 60
    public static let installmentRange = 1...12

    public let id: UUID
    public let kind: RecordKind
    /// Valor total. Numa compra parcelada, o detalhe preserva o total (CONTEXT.md).
    public let amount: Cents
    public let description: String
    /// Obrigatória no gasto; ausente na receita.
    public let category: RecordCategory?
    public let source: PaymentSource
    public let day: CalendarDay
    /// Maior que 1 só em gasto no cartão.
    public let installments: Int
    /// Momento da gravação, para ordenar registros do mesmo dia.
    public let savedAt: Date

    public init(id: UUID = UUID(), kind: RecordKind, amount: Cents, description: String,
                category: RecordCategory?, source: PaymentSource, day: CalendarDay,
                installments: Int = 1, savedAt: Date) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.description = Self.normalized(description)
        self.category = kind == .income ? nil : category
        self.source = source
        self.day = day
        self.installments = installments
        self.savedAt = savedAt
    }

    /// Descrição sem espaços nas pontas e com no máximo 60 caracteres.
    public static func normalized(_ description: String) -> String {
        String(description.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxDescriptionLength))
    }

    public var isValid: Bool {
        guard amount.value > 0, amount <= Self.maxAmount,
              Self.installmentRange.contains(installments) else { return false }
        switch kind {
        case .expense:
            return category != nil && (installments == 1 || source.isCard)
        case .income:
            return !source.isCard && installments == 1
        }
    }

    /// Nome nas listas: a descrição; sem ela, a categoria do gasto ou "Receita".
    public var displayName: String {
        if !description.isEmpty { return description }
        return category?.name ?? "Receita"
    }
}

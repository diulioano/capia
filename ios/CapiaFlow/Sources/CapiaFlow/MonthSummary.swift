import Foundation

/// Totais do mês em centavos. Confirmados e previstos ficam separados, e a fatura fica à
/// parte: gastos no cartão já contam como gastos, e pagar a fatura não é um novo gasto.
/// O saldo inicial das contas nunca entra aqui (CONTEXT.md).
public struct MonthTotals: Equatable, Sendable {
    public static let zero = MonthTotals()

    /// Nível de água sem receitas ou sem sobra, e o acréscimo por ponto percentual (design).
    public static let minimumWaterLevel = 0.18
    public static let waterLevelPerPercent = 0.0062

    public var income: Cents
    public var expenses: Cents
    public var forecastIncome: Cents
    public var forecastExpenses: Cents
    public var bill: Cents

    public init(income: Cents = .zero, expenses: Cents = .zero, forecastIncome: Cents = .zero,
                forecastExpenses: Cents = .zero, bill: Cents = .zero) {
        self.income = income
        self.expenses = expenses
        self.forecastIncome = forecastIncome
        self.forecastExpenses = forecastExpenses
        self.bill = bill
    }

    /// Saldo do mês até agora: receitas confirmadas menos gastos confirmados.
    public var balance: Int64 { income.value - expenses.value }

    /// Sobra prevista no fim do mês: o saldo somado às receitas previstas e subtraído dos
    /// gastos previstos ainda não confirmados.
    public var forecastBalance: Int64 { balance + forecastIncome.value - forecastExpenses.value }

    /// Parte das receitas ainda disponível, de 0 a 100, arredondada para o inteiro mais
    /// próximo (meio para cima). Ausente quando não há receitas.
    public var availablePercent: Int? {
        guard income.value > 0 else { return nil }
        guard balance > 0 else { return 0 }
        let rounded = (balance * 200 + income.value) / (income.value * 2)
        return Int(Swift.min(rounded, 100))
    }

    /// Altura da água no cartão do saldo, de 18% a 80%.
    public var waterLevel: Double {
        Self.minimumWaterLevel + Double(availablePercent ?? 0) * Self.waterLevelPerPercent
    }
}

/// Saudação e nome do mês pelo relógio e fuso do aparelho, iguais no Linux e no iPhone.
public struct MonthCalendar: Equatable, Sendable {
    public enum Greeting: Equatable, Sendable {
        case morning, afternoon, evening
    }

    public static let monthNames = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
                                    "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]

    public let greeting: Greeting
    /// Mês atual em português, com inicial maiúscula.
    public let monthName: String
    /// Ano e mês, para detectar a virada do mês.
    public let year: Int
    public let month: Int
    /// Dia de hoje e fuso, para a fatura aberta e as datas dos registros.
    public let day: Int
    public let timeZone: TimeZone

    public init(date: Date, timeZone: TimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let hour = parts.hour ?? 0
        greeting = switch hour {
        case 5..<12: .morning
        case 12..<18: .afternoon
        default: .evening
        }
        year = parts.year ?? 0
        month = parts.month ?? 1
        day = parts.day ?? 1
        self.timeZone = timeZone
        monthName = Self.monthNames[(month - 1) % 12]
    }

    public var yearMonth: YearMonth { YearMonth(year: year, month: month) }
    public var today: CalendarDay { CalendarDay(year: year, month: month, day: day) }
}

/// Situação do salário no mês exibido.
public enum SalaryStatus: Equatable, Sendable {
    /// Previsto e ainda não confirmado: entra só na sobra prevista.
    case pending(Cents)
    /// Confirmado com "Recebi": conta como receita do mês e soma ao dinheiro em contas.
    case received(SalaryReceipt)

    public var amount: Cents {
        switch self {
        case .pending(let amount): amount
        case .received(let receipt): receipt.amount
        }
    }
}

/// Parte dos gastos do mês numa categoria.
public struct CategoryShare: Equatable, Sendable {
    public let category: RecordCategory
    public let amount: Cents
    /// Percentual dos gastos do mês, arredondado (meio para cima).
    public let percent: Int
}

/// Parte das receitas do mês agrupadas pelo nome exibido.
public struct IncomeShare: Equatable, Sendable {
    public let name: String
    public let amount: Cents
    public let percent: Int
}

/// Linha de "Registros recentes": um registro ou um salário recebido.
public struct RecentItem: Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let kind: RecordKind
    /// Total da compra, mesmo quando parcelada.
    public let amount: Cents
    public let category: RecordCategory?
    /// Conta pelo nome ou "Cartão {nome}". Ausente no salário e em fontes que não existem mais.
    public let sourceName: String?
    public let installments: Int
    public let day: CalendarDay
    public let isSalary: Bool
}

/// O que o Início mostra a partir do espaço configurado.
public struct MonthSummary: Equatable, Sendable {
    public static let recentLimit = 5

    public let firstName: String
    public let hasCard: Bool
    public let totals: MonthTotals
    public let calendar: MonthCalendar
    /// Ausente quando a pessoa não informou salário.
    public let salary: SalaryStatus?
    /// Dinheiro nas contas hoje. Distinto do saldo do mês e da sobra; pode ser negativo.
    public let accountsBalance: Int64
    public let expenseBreakdown: [CategoryShare]
    public let incomeBreakdown: [IncomeShare]
    public let recent: [RecentItem]
    public let hasRecords: Bool

    /// O saldo inicial não é receita do mês; o salário só é receita depois de confirmado.
    /// Gastos em conta e receitas contam no mês da data; compras no cartão contam cada
    /// parcela no mês da compra somado à posição menos um. A fatura soma as faturas abertas.
    public init(space: ConfiguredSpace, calendar: MonthCalendar) {
        let name = space.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        firstName = name.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? name
        hasCard = !space.cards.isEmpty
        self.calendar = calendar
        accountsBalance = space.accountsBalance
        hasRecords = !space.records.isEmpty

        let month = calendar.yearMonth
        let today = calendar.today
        let accountIDs = Set(space.accounts.map(\.id))
        let cardsByID = Dictionary(space.cards.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let openInvoices = Set(space.cards.map { CardBilling(card: $0).openInvoice(today: today) })

        var income: Int64 = 0
        var expenses: Int64 = 0
        var bill: Int64 = 0
        var byCategory: [RecordCategory: Int64] = [:]
        var incomeGroups: [(name: String, amount: Int64)] = []

        func addIncome(_ name: String, _ amount: Int64) {
            income += amount
            if let index = incomeGroups.firstIndex(where: { $0.name == name }) {
                incomeGroups[index].amount += amount
            } else {
                incomeGroups.append((name, amount))
            }
        }

        var forecastIncome = Cents.zero
        if let receipt = space.salaryReceipt(year: calendar.year, month: calendar.month) {
            salary = .received(receipt)
            addIncome("Salário", receipt.amount.value)
        } else if let amount = space.monthlySalary {
            salary = .pending(amount)
            forecastIncome = amount
        } else {
            salary = nil
        }

        for record in space.records {
            switch record.source {
            case .account(let id):
                guard accountIDs.contains(id), record.day.yearMonth == month else { continue }
                if record.kind == .income {
                    addIncome(record.displayName, record.amount.value)
                } else if let category = record.category {
                    expenses += record.amount.value
                    byCategory[category, default: 0] += record.amount.value
                }
            case .card(let id):
                guard let card = cardsByID[id], let category = record.category else { continue }
                for installment in record.installments(card: card) {
                    if installment.countsIn == month {
                        expenses += installment.amount.value
                        byCategory[category, default: 0] += installment.amount.value
                    }
                    if openInvoices.contains(installment.invoice) { bill += installment.amount.value }
                }
            }
        }

        totals = MonthTotals(income: Cents(income), expenses: Cents(expenses),
                             forecastIncome: forecastIncome, bill: Cents(bill))

        let expenseTotal = expenses
        let categories = RecordCategory.allCases.compactMap { category in
            byCategory[category].map { (category: category, amount: $0) }
        }
        // Ordenação estável: maior valor primeiro; empate pela ordem do quadro.
        expenseBreakdown = categories.enumerated()
            .sorted { lhs, rhs in
                lhs.element.amount != rhs.element.amount
                    ? lhs.element.amount > rhs.element.amount : lhs.offset < rhs.offset
            }
            .map { entry in
                CategoryShare(category: entry.element.category, amount: Cents(entry.element.amount),
                              percent: Self.percent(entry.element.amount, of: expenseTotal))
            }

        let incomeTotal = income
        incomeBreakdown = incomeGroups.enumerated()
            .sorted { lhs, rhs in
                lhs.element.amount != rhs.element.amount
                    ? lhs.element.amount > rhs.element.amount : lhs.offset < rhs.offset
            }
            .map { entry in
                IncomeShare(name: entry.element.name, amount: Cents(entry.element.amount),
                            percent: Self.percent(entry.element.amount, of: incomeTotal))
            }

        var items: [(item: RecentItem, savedAt: Date)] = space.records.map { record in
            let sourceName: String?
            switch record.source {
            case .account(let id): sourceName = space.accounts.first { $0.id == id }?.name
            case .card(let id): sourceName = cardsByID[id].map { "Cartão \($0.name)" }
            }
            let item = RecentItem(id: record.id.uuidString, name: record.displayName, kind: record.kind,
                                  amount: record.amount, category: record.category, sourceName: sourceName,
                                  installments: record.installments, day: record.day, isSalary: false)
            return (item, record.savedAt)
        }
        let timeZone = calendar.timeZone
        items += space.salaryReceipts.map { receipt in
            let item = RecentItem(id: "salary-\(receipt.year)-\(receipt.month)", name: "Salário", kind: .income,
                                  amount: receipt.amount, category: nil, sourceName: nil, installments: 1,
                                  day: CalendarDay(date: receipt.confirmedAt, timeZone: timeZone),
                                  isSalary: true)
            return (item, receipt.confirmedAt)
        }
        recent = items
            .sorted { lhs, rhs in
                lhs.item.day != rhs.item.day ? lhs.item.day > rhs.item.day : lhs.savedAt > rhs.savedAt
            }
            .prefix(Self.recentLimit)
            .map(\.item)
    }

    /// Percentual inteiro, arredondado meio para cima.
    static func percent(_ part: Int64, of total: Int64) -> Int {
        guard total > 0 else { return 0 }
        return Int((part * 200 + total) / (total * 2))
    }
}

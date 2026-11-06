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

    public init(date: Date, timeZone: TimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .hour], from: date)
        let hour = parts.hour ?? 0
        greeting = switch hour {
        case 5..<12: .morning
        case 12..<18: .afternoon
        default: .evening
        }
        year = parts.year ?? 0
        month = parts.month ?? 1
        monthName = Self.monthNames[(month - 1) % 12]
    }
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

/// O que o Início mostra a partir do espaço configurado.
public struct MonthSummary: Equatable, Sendable {
    public let firstName: String
    public let hasCard: Bool
    public let totals: MonthTotals
    public let calendar: MonthCalendar
    /// Ausente quando a pessoa não informou salário.
    public let salary: SalaryStatus?
    /// Saldos iniciais mais salários recebidos. Distinto do saldo do mês e da sobra.
    public let accountsTotal: Cents

    /// O saldo inicial não é receita do mês; o salário só é receita depois de confirmado.
    public init(space: ConfiguredSpace, calendar: MonthCalendar) {
        let name = space.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        firstName = name.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? name
        hasCard = !space.cards.isEmpty
        self.calendar = calendar
        accountsTotal = space.accountsTotal
        if let receipt = space.salaryReceipt(year: calendar.year, month: calendar.month) {
            salary = .received(receipt)
            totals = MonthTotals(income: receipt.amount)
        } else if let amount = space.monthlySalary {
            salary = .pending(amount)
            totals = MonthTotals(forecastIncome: amount)
        } else {
            salary = nil
            totals = .zero
        }
    }
}

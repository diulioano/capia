import Foundation

/// Objetivos oferecidos na etapa "o que te trouxe aqui?", na ordem do design.
public enum SetupGoal: String, CaseIterable, Codable, Hashable, Sendable {
    case understandSpending, saveForGoal, organizeCardBills, leaveSpreadsheet
}

/// Tipo de conta. Conta é distinta de cartão de crédito (CONTEXT.md).
public enum AccountKind: String, CaseIterable, Codable, Hashable, Sendable {
    case checking, savings, wallet
}

public struct Profile: Codable, Equatable, Sendable {
    public var name: String
    public var goals: Set<SetupGoal>

    public init(name: String, goals: Set<SetupGoal>) {
        self.name = name
        self.goals = goals
    }
}

/// Origem ou destino de dinheiro, com saldo inicial na data em que passa a ser acompanhada.
public struct Account: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var kind: AccountKind
    public var name: String
    public var initialBalance: Cents

    public init(id: UUID = UUID(), kind: AccountKind, name: String, initialBalance: Cents) {
        self.id = id
        self.kind = kind
        self.name = name
        self.initialBalance = initialBalance
    }
}

/// Meio de pagamento com fatura própria. Não tem saldo e não é uma conta.
public struct CreditCard: Codable, Equatable, Identifiable, Sendable {
    public static let days = 1...31
    /// Distância sugerida entre fechamento e vencimento.
    public static let suggestedGap = 7
    /// Faixa usual entre fechamento e vencimento. Fora dela o app só avisa; não é regra.
    public static let typicalGap = 5...15

    /// Dias do fechamento até o vencimento seguinte, contando um mês nominal de 30 dias.
    /// Vencimento com número menor que o fechamento cai no mês seguinte (fecha 25, vence 5).
    public static func gap(closingDay: Int, dueDay: Int) -> Int {
        dueDay > closingDay ? dueDay - closingDay : dueDay + 30 - closingDay
    }

    /// Vencimento sugerido para um fechamento: sete dias depois, dentro de 1…31.
    public static func suggestedDueDay(closingDay: Int) -> Int {
        let day = closingDay + suggestedGap
        return day > 31 ? day - 30 : day
    }

    public static func dueIsNextMonth(closingDay: Int, dueDay: Int) -> Bool {
        dueDay < closingDay
    }

    public let id: UUID
    public var name: String
    public var closingDay: Int
    public var dueDay: Int

    public init(id: UUID = UUID(), name: String, closingDay: Int, dueDay: Int) {
        self.id = id
        self.name = name
        self.closingDay = closingDay
        self.dueDay = dueDay
    }
}

/// Espaço confirmado na conclusão da configuração e guardado no aparelho.
public struct ConfiguredSpace: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    public var profile: Profile
    public var accounts: [Account]
    public var cards: [CreditCard]
    public var completedAt: Date
    /// Salário mensal informado na configuração: uma receita recorrente prevista.
    /// Ausente quando a pessoa deixa zero. Só altera valores depois de "Recebi".
    public var monthlySalary: Cents?
    /// Recebimentos do salário confirmados pela pessoa, um por mês no máximo.
    public var salaryReceipts: [SalaryReceipt]

    public init(profile: Profile, accounts: [Account], cards: [CreditCard], completedAt: Date,
                monthlySalary: Cents? = nil, salaryReceipts: [SalaryReceipt] = []) {
        self.schemaVersion = Self.currentSchemaVersion
        self.profile = profile
        self.accounts = accounts
        self.cards = cards
        self.completedAt = completedAt
        self.monthlySalary = monthlySalary.flatMap { $0 == .zero ? nil : $0 }
        self.salaryReceipts = salaryReceipts
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, profile, accounts, cards, completedAt, monthlySalary, salaryReceipts
    }

    /// Espaços gravados antes do salário não têm as duas chaves novas; continuam válidos
    /// na mesma versão do esquema, sem salário e sem recebimentos.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        profile = try container.decode(Profile.self, forKey: .profile)
        accounts = try container.decode([Account].self, forKey: .accounts)
        cards = try container.decode([CreditCard].self, forKey: .cards)
        completedAt = try container.decode(Date.self, forKey: .completedAt)
        monthlySalary = try container.decodeIfPresent(Cents.self, forKey: .monthlySalary)
        salaryReceipts = try container.decodeIfPresent([SalaryReceipt].self, forKey: .salaryReceipts) ?? []
    }

    /// Recebimento confirmado no mês, se houver.
    public func salaryReceipt(year: Int, month: Int) -> SalaryReceipt? {
        salaryReceipts.first { $0.year == year && $0.month == month }
    }

    /// Dinheiro nas contas hoje: saldos iniciais somados aos salários já recebidos.
    /// Não inclui previstos nem cartões, que não têm saldo.
    public var accountsTotal: Cents {
        let initial = accounts.reduce(Cents.zero) { $0.adding($1.initialBalance) }
        return salaryReceipts.reduce(initial) { $0.adding($1.amount) }
    }
}

/// Confirmação de que o salário de um mês entrou. Guarda o valor da época, para que
/// mudar o salário depois não reescreva meses passados.
public struct SalaryReceipt: Codable, Equatable, Sendable {
    public let year: Int
    public let month: Int
    public let amount: Cents
    public let confirmedAt: Date

    public init(year: Int, month: Int, amount: Cents, confirmedAt: Date) {
        self.year = year
        self.month = month
        self.amount = amount
        self.confirmedAt = confirmedAt
    }
}

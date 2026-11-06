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

    /// Primeira palavra do nome, usada nos cumprimentos.
    public var greeting: String {
        name.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? ""
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

    public init(profile: Profile, accounts: [Account], cards: [CreditCard], completedAt: Date) {
        self.schemaVersion = Self.currentSchemaVersion
        self.profile = profile
        self.accounts = accounts
        self.cards = cards
        self.completedAt = completedAt
    }
}

import CapiaFlow

/// Textos do Início. Os do quadro "Resumo do mês" são literais do design; os estados sem
/// registros são complementos registrados em `specs/003-month-summary/contracts/`.
enum HomeCopy {
    static func greeting(_ greeting: MonthCalendar.Greeting) -> String {
        switch greeting {
        case .morning: "Bom dia"
        case .afternoon: "Boa tarde"
        case .evening: "Boa noite"
        }
    }

    static func capybaraMessage(firstName: String, salary: SalaryStatus?) -> String {
        if case .pending = salary {
            return "Oi, \(firstName)! Seu salário já está previsto. Quando ele cair, é só tocar em Recebi."
        }
        return "Oi, \(firstName)! Seu mês começa aqui. Conforme você registra, eu mostro para onde o dinheiro vai."
    }

    /// Resposta ao "Recebi", como no quadro, sem citar metas, que ainda não existem.
    static let salaryReceivedMessage = "Entrou! Seu mês já conta com isso."

    static let accountsTitle = "Em contas hoje:"

    static let balanceTitle = "Saldo do mês até agora"
    static let forecastTitle = "Sobra prevista no fim do mês:"
    static let noIncome = "Nenhuma receita registrada neste mês"
    static let hiddenBadge = "Valores ocultos"
    static let noCard = "Sem cartão"

    static func availableBadge(_ totals: MonthTotals, hidden: Bool) -> String {
        if hidden { return hiddenBadge }
        guard let percent = totals.availablePercent else { return noIncome }
        return "\(percent)% das receitas ainda com você"
    }

    /// Valor exibido; oculto vira `R$ ••••`.
    static func money(_ cents: Cents, hidden: Bool) -> String {
        hidden ? BRL.hidden : BRL.format(cents)
    }

    static func money(signed cents: Int64, hidden: Bool) -> String {
        hidden ? BRL.hidden : BRL.format(signed: cents)
    }

    /// Leitura assistiva: nunca revela o montante quando oculto.
    static func spoken(_ text: String, hidden: Bool) -> String {
        hidden ? "valor oculto" : text
    }
}

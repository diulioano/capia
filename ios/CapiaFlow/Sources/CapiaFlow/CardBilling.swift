import Foundation

/// Ciclo de um cartão, identificado pelo mês em que fecha. Leva o nome do mês do
/// vencimento ("fatura de dezembro").
public struct Invoice: Hashable, Sendable {
    public let cardID: UUID
    public let closing: YearMonth
    public let due: YearMonth

    public func adding(months: Int, billing: CardBilling) -> Invoice {
        billing.invoice(closingIn: closing.adding(months: months))
    }
}

/// Regras de fatura do protótipo (research §4). O ciclo real continua em aberto em
/// `docs/descoberta.md`; isto é uma premissa desta entrega, não regra definitiva.
public struct CardBilling: Sendable {
    public let card: CreditCard

    public init(card: CreditCard) {
        self.card = card
    }

    /// Dia do fechamento num mês: o dia do cartão ou o último dia do mês, se ele não existir.
    public func effectiveClosingDay(in month: YearMonth) -> Int {
        Swift.min(card.closingDay, month.dayCount)
    }

    /// Fatura que fecha no mês. Vence no mesmo mês ou, se o vencimento tem número menor que
    /// o fechamento, no seguinte, como na configuração.
    public func invoice(closingIn month: YearMonth) -> Invoice {
        let due = CreditCard.dueIsNextMonth(closingDay: card.closingDay, dueDay: card.dueDay)
            ? month.adding(months: 1) : month
        return Invoice(cardID: card.id, closing: month, due: due)
    }

    /// Fatura em que entra uma compra do dia: a que fecha no mês se a compra é até o
    /// fechamento (inclusive); senão, a que fecha no mês seguinte.
    public func invoice(forPurchase day: CalendarDay) -> Invoice {
        let month = day.yearMonth
        return day.day <= effectiveClosingDay(in: month)
            ? invoice(closingIn: month)
            : invoice(closingIn: month.adding(months: 1))
    }

    /// Fatura aberta hoje: a que fecha no próximo fechamento, contando o dia de hoje.
    public func openInvoice(today: CalendarDay) -> Invoice {
        invoice(forPurchase: today)
    }
}

/// Parte de uma compra no cartão. Conta nos gastos do mês da compra somado à posição menos
/// um (decisão do usuário em 2026-11-06) e pertence a uma fatura.
public struct Installment: Equatable, Sendable {
    public let index: Int
    public let amount: Cents
    public let countsIn: YearMonth
    public let invoice: Invoice
}

extension Record {
    /// Valores das parcelas: a divisão inteira para todas e o resto na primeira, somando
    /// exatamente o total.
    public static func installmentAmounts(total: Cents, count: Int) -> [Cents] {
        let count = Swift.max(1, count)
        let base = total.value / Int64(count)
        let rest = total.value % Int64(count)
        return (0..<count).map { Cents($0 == 0 ? base + rest : base) }
    }

    /// Parcelas de um gasto no cartão indicado. Vazio para receitas e gastos em conta.
    public func installments(card: CreditCard) -> [Installment] {
        guard kind == .expense, case .card(let id) = source, id == card.id else { return [] }
        let billing = CardBilling(card: card)
        let first = billing.invoice(forPurchase: day)
        return Self.installmentAmounts(total: amount, count: installments).enumerated().map { offset, value in
            Installment(index: offset + 1, amount: value,
                        countsIn: day.yearMonth.adding(months: offset),
                        invoice: first.adding(months: offset, billing: billing))
        }
    }
}

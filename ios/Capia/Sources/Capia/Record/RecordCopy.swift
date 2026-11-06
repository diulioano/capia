import CapiaFlow
import Foundation

/// Textos do quadro "Novo registro" e complementos registrados no contrato.
enum RecordCopy {
    static let closeLabel = "Fechar e voltar ao resumo"
    static let saveFailed = "Não deu para salvar agora. Tente de novo."
    static let retry = "Tentar de novo"
    static let saved = "Registro salvo"
    static let undo = "Desfazer"

    static func title(_ flow: RecordFlow) -> String {
        flow.mode == .type && flow.phase == .details ? "Revisar registro" : "Novo registro"
    }

    static func modeLabel(_ mode: RecordMode) -> String {
        switch mode {
        case .type: "Digitar"
        case .speak: "Falar"
        case .photo: "Foto"
        }
    }

    static func kindLabel(_ kind: RecordKind) -> String {
        kind == .expense ? "Gasto" : "Receita"
    }

    static func padHint(_ kind: RecordKind) -> String {
        kind == .expense ? "Quanto você gastou?" : "Quanto você recebeu?"
    }

    static func sourceLabel(_ kind: RecordKind) -> String {
        kind == .expense ? "Pago com" : "Entrou em"
    }

    static func formSubtitle(_ kind: RecordKind) -> String {
        kind == .expense ? "Escolha a categoria e pronto." : "Escolha onde entrou e pronto."
    }

    static func modePlaceholder(_ mode: RecordMode) -> String {
        switch mode {
        case .speak: "Registrar falando vem na próxima etapa do protótipo. Por enquanto, use Digitar."
        case .photo: "Registrar por foto vem na próxima etapa do protótipo. Por enquanto, use Digitar."
        case .type: ""
        }
    }

    /// Conta pelo nome; cartão como "Cartão {nome}", distinto de conta (CONTEXT.md).
    static func sourceName(_ source: PaymentSource?, accounts: [Account], cards: [CreditCard]) -> String {
        switch source {
        case .account(let id)?: accounts.first { $0.id == id }?.name ?? "Conta"
        case .card(let id)?: cards.first { $0.id == id }.map { "Cartão \($0.name)" } ?? "Cartão"
        case nil: ""
        }
    }

    /// `+ R$ 1.150,00 · Freela · site · Conta Aurora`; o "+" só na receita.
    static func toastSubtitle(_ record: Record, accounts: [Account], cards: [CreditCard]) -> String {
        let sign = record.kind == .income ? "+ " : ""
        let source = sourceName(record.source, accounts: accounts, cards: cards)
        return "\(sign)\(BRL.format(record.amount)) · \(record.displayName) · \(source)"
    }

    /// "À vista, na fatura de dezembro" ou "3× de R$ 200,00 · até fev".
    static func installmentsText(card: CreditCard, amount: Cents, count: Int, purchase: CalendarDay) -> String {
        let billing = CardBilling(card: card)
        let first = billing.invoice(forPurchase: purchase)
        guard count > 1 else { return "À vista, na fatura de \(first.due.name)" }
        let last = first.adding(months: count - 1, billing: billing)
        let regular = Record.installmentAmounts(total: amount, count: count).last ?? amount
        return "\(count)× de \(BRL.format(regular)) · até \(last.due.shortName)"
    }

    /// Dia que a escolha de data representa agora, para o texto da fatura.
    static func day(for choice: DateChoice, now: Date = Date(), timeZone: TimeZone = .current) -> CalendarDay {
        switch choice {
        case .today: CalendarDay.today(now: now, timeZone: timeZone)
        case .yesterday: CalendarDay.yesterday(now: now, timeZone: timeZone)
        case .other(let day): day
        }
    }
}

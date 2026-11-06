import CapiaFlow
import Foundation
import XCTest

final class CardBillingTests: XCTestCase {
    private let saved = Date(timeIntervalSince1970: 1_793_000_000)

    private func card(closing: Int, due: Int) -> CreditCard {
        CreditCard(name: "Aurora", closingDay: closing, dueDay: due)
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> CalendarDay {
        CalendarDay(year: year, month: month, day: day)
    }

    private func ym(_ year: Int, _ month: Int) -> YearMonth { YearMonth(year: year, month: month) }

    func testPurchaseBeforeOnAndAfterClosing() {
        let billing = CardBilling(card: card(closing: 3, due: 10))
        XCTAssertEqual(billing.invoice(forPurchase: day(2026, 11, 2)).closing, ym(2026, 11))
        XCTAssertEqual(billing.invoice(forPurchase: day(2026, 11, 3)).closing, ym(2026, 11), "Dia do fechamento entra")
        let after = billing.invoice(forPurchase: day(2026, 11, 5))
        XCTAssertEqual(after.closing, ym(2026, 12))
        XCTAssertEqual(after.due, ym(2026, 12), "Fatura de dezembro, como no quadro")
    }

    func testClosingDayMissingInShortMonths() {
        let billing = CardBilling(card: card(closing: 31, due: 7))
        XCTAssertEqual(billing.effectiveClosingDay(in: ym(2026, 11)), 30)
        XCTAssertEqual(billing.effectiveClosingDay(in: ym(2027, 2)), 28)
        XCTAssertEqual(billing.effectiveClosingDay(in: ym(2028, 2)), 29)
        XCTAssertEqual(billing.invoice(forPurchase: day(2026, 11, 30)).closing, ym(2026, 11))
        XCTAssertEqual(billing.invoice(forPurchase: day(2027, 2, 28)).closing, ym(2027, 2))
    }

    func testDueInTheFollowingMonthWhenDueDayIsSmaller() {
        let billing = CardBilling(card: card(closing: 25, due: 5))
        let invoice = billing.invoice(forPurchase: day(2026, 11, 10))
        XCTAssertEqual(invoice.closing, ym(2026, 11))
        XCTAssertEqual(invoice.due, ym(2026, 12))
    }

    func testYearTurn() {
        let billing = CardBilling(card: card(closing: 3, due: 10))
        let invoice = billing.invoice(forPurchase: day(2026, 12, 20))
        XCTAssertEqual(invoice.closing, ym(2027, 1))
        XCTAssertEqual(invoice.due, ym(2027, 1))
    }

    func testOpenInvoiceIncludesClosingDay() {
        let billing = CardBilling(card: card(closing: 3, due: 10))
        XCTAssertEqual(billing.openInvoice(today: day(2026, 11, 3)).closing, ym(2026, 11))
        XCTAssertEqual(billing.openInvoice(today: day(2026, 11, 4)).closing, ym(2026, 12))
    }

    func testInstallmentAmountsSumExactlyWithRestOnFirst() {
        XCTAssertEqual(Record.installmentAmounts(total: Cents(10_000), count: 3),
                       [Cents(3_334), Cents(3_333), Cents(3_333)])
        XCTAssertEqual(Record.installmentAmounts(total: Cents(60_000), count: 3),
                       [Cents(20_000), Cents(20_000), Cents(20_000)])
        for total in [Int64(1), 7, 10_000, 99_999_999] {
            for count in 1...12 {
                let parts = Record.installmentAmounts(total: Cents(total), count: count)
                XCTAssertEqual(parts.count, count)
                XCTAssertEqual(parts.reduce(Int64(0)) { $0 + $1.value }, total, "\(total) em \(count)×")
            }
        }
    }

    func testInstallmentMonthsAndInvoices() {
        let aurora = card(closing: 3, due: 10)
        let record = Record(kind: .expense, amount: Cents(60_000), description: "Fone", category: .shopping,
                            source: .card(id: aurora.id), day: day(2026, 11, 5), installments: 3, savedAt: saved)
        let parts = record.installments(card: aurora)
        XCTAssertEqual(parts.map(\.index), [1, 2, 3])
        XCTAssertEqual(parts.map(\.countsIn), [ym(2026, 11), ym(2026, 12), ym(2027, 1)],
                       "Conta no mês da compra e nos seguintes")
        XCTAssertEqual(parts.map(\.invoice.due), [ym(2026, 12), ym(2027, 1), ym(2027, 2)])
    }

    func testOnlyCardExpensesHaveInstallments() {
        let aurora = card(closing: 3, due: 10)
        let other = card(closing: 3, due: 10)
        let record = Record(kind: .expense, amount: Cents(1_000), description: "", category: .other,
                            source: .card(id: aurora.id), day: day(2026, 11, 5), savedAt: saved)
        XCTAssertEqual(record.installments(card: other), [])
        XCTAssertEqual(record.installments(card: aurora).count, 1)
    }
}

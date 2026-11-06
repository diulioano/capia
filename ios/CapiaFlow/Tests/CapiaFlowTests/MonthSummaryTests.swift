import CapiaFlow
import Foundation
import XCTest

final class MonthSummaryTests: XCTestCase {
    private let saoPaulo = TimeZone(identifier: "America/Sao_Paulo")!

    /// Data em 2026, no horário de São Paulo (UTC−3).
    private func date(month: Int = 11, day: Int = 6, hour: Int, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = saoPaulo
        return calendar.date(from: DateComponents(year: 2026, month: month, day: day,
                                                  hour: hour, minute: minute))!
    }

    func testZeroTotalsHaveNoIncomeAndMinimumWater() {
        let totals = MonthTotals.zero
        XCTAssertEqual(totals.balance, 0)
        XCTAssertEqual(totals.forecastBalance, 0)
        XCTAssertNil(totals.availablePercent)
        XCTAssertEqual(totals.waterLevel, 0.18, accuracy: 1e-9)
    }

    func testBalanceAndForecastFollowTheDesignFormula() {
        // Valores do quadro: receitas 7.350,00, gastos 2.412,60, previstos +500 e −1.919,90.
        let totals = MonthTotals(income: Cents(735_000), expenses: Cents(241_260),
                                 forecastIncome: Cents(50_000), forecastExpenses: Cents(191_990),
                                 bill: Cents(194_030))
        XCTAssertEqual(totals.balance, 493_740)
        XCTAssertEqual(totals.forecastBalance, 351_750)
        XCTAssertEqual(totals.availablePercent, 67)
        XCTAssertEqual(totals.waterLevel, 0.18 + 67 * 0.0062, accuracy: 1e-9)
        XCTAssertEqual(BRL.format(signed: totals.balance), "R$ 4.937,40")
    }

    func testBillDoesNotChangeTheBalance() {
        let without = MonthTotals(income: Cents(10_000), expenses: Cents(4_000))
        var with = without
        with.bill = Cents(4_000)
        XCTAssertEqual(with.balance, without.balance)
        XCTAssertEqual(with.forecastBalance, without.forecastBalance)
    }

    func testNegativeBalanceKeepsSignAndMinimumWater() {
        let totals = MonthTotals(income: Cents(10_000), expenses: Cents(12_350), forecastExpenses: Cents(1_000))
        XCTAssertEqual(totals.balance, -2_350)
        XCTAssertEqual(totals.forecastBalance, -3_350)
        XCTAssertEqual(totals.availablePercent, 0)
        XCTAssertEqual(totals.waterLevel, 0.18, accuracy: 1e-9)
        XCTAssertEqual(BRL.format(signed: totals.balance), "\u{2212} R$ 23,50")
    }

    func testAvailablePercentRoundsHalfUpAndCapsAtHundred() {
        XCTAssertEqual(MonthTotals(income: Cents(200), expenses: Cents(1)).availablePercent, 100, "99,5%")
        XCTAssertEqual(MonthTotals(income: Cents(1_000), expenses: Cents(6)).availablePercent, 99, "99,4%")
        XCTAssertEqual(MonthTotals(income: Cents(300), expenses: Cents(200)).availablePercent, 33)
        XCTAssertEqual(MonthTotals(income: Cents(300), expenses: Cents(100)).availablePercent, 67)
        XCTAssertEqual(MonthTotals(income: Cents(10_000)).availablePercent, 100)
        XCTAssertEqual(MonthTotals(income: Cents(10_000)).waterLevel, 0.80, accuracy: 1e-9)
        XCTAssertEqual(MonthTotals(income: .max).availablePercent, 100)
    }

    func testGreetingBoundaries() {
        let cases: [(Int, Int, MonthCalendar.Greeting)] = [
            (4, 59, .evening), (5, 0, .morning), (11, 59, .morning), (12, 0, .afternoon),
            (17, 59, .afternoon), (18, 0, .evening), (23, 59, .evening), (0, 0, .evening)
        ]
        for (hour, minute, expected) in cases {
            XCTAssertEqual(MonthCalendar(date: date(hour: hour, minute: minute), timeZone: saoPaulo).greeting,
                           expected, "\(hour):\(minute)")
        }
    }

    func testGreetingAndMonthUseTheDeviceTimeZone() {
        // 2026-12-01 01:00 em São Paulo é 2026-11-30 20:00 em Los Angeles.
        let instant = date(month: 12, day: 1, hour: 1)
        let local = MonthCalendar(date: instant, timeZone: saoPaulo)
        XCTAssertEqual(local.monthName, "Dezembro")
        XCTAssertEqual(local.greeting, .evening)
        let west = MonthCalendar(date: instant, timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        XCTAssertEqual(west.monthName, "Novembro")
        XCTAssertEqual(west.month, 11)
        XCTAssertEqual(west.year, 2026)
        XCTAssertEqual(west.greeting, .evening)
    }

    func testAllMonthNamesInPortuguese() {
        let names = (1...12).map {
            MonthCalendar(date: date(month: $0, day: 15, hour: 12), timeZone: saoPaulo).monthName
        }
        XCTAssertEqual(names, ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
                               "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"])
    }

    func testSummaryUsesFirstNameAndIgnoresInitialBalance() {
        let space = ConfiguredSpace(
            profile: Profile(name: "  Diuli Vargas ", goals: [.understandSpending]),
            accounts: [Account(kind: .checking, name: "Banco Aurora", initialBalance: Cents(123_456))],
            cards: [], completedAt: Date(timeIntervalSince1970: 0))
        let calendar = MonthCalendar(date: date(hour: 20), timeZone: saoPaulo)
        let summary = MonthSummary(space: space, calendar: calendar)
        XCTAssertEqual(summary.firstName, "Diuli")
        XCTAssertFalse(summary.hasCard)
        XCTAssertEqual(summary.totals, .zero, "Saldo inicial não é receita")
        XCTAssertEqual(summary.calendar.monthName, "Novembro")

        var withCard = space
        withCard.cards = [CreditCard(name: "Banco Aurora", closingDay: 3, dueDay: 10)]
        XCTAssertTrue(MonthSummary(space: withCard, calendar: calendar).hasCard)
    }
}

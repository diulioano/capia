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

    private func space(salary: Cents?, receipts: [SalaryReceipt] = []) -> ConfiguredSpace {
        ConfiguredSpace(
            profile: Profile(name: "Diuli", goals: [.understandSpending]),
            accounts: [Account(kind: .checking, name: "Banco Aurora", initialBalance: Cents(100_000)),
                       Account(kind: .wallet, name: "Carteira", initialBalance: Cents(5_050))],
            cards: [], completedAt: Date(timeIntervalSince1970: 0),
            monthlySalary: salary, salaryReceipts: receipts)
    }

    func testPendingSalaryOnlyEntersTheForecast() {
        let november = MonthCalendar(date: date(hour: 9), timeZone: saoPaulo)
        let summary = MonthSummary(space: space(salary: Cents(620_000)), calendar: november)
        XCTAssertEqual(summary.salary, .pending(Cents(620_000)))
        XCTAssertEqual(summary.totals.income, .zero)
        XCTAssertEqual(summary.totals.balance, 0)
        XCTAssertEqual(summary.totals.forecastBalance, 620_000)
        XCTAssertNil(summary.totals.availablePercent, "Previsto não é receita")
        XCTAssertEqual(summary.accountsBalance, 105_050, "Previsto não está nas contas")
    }

    func testReceivedSalaryCountsInItsMonthOnly() {
        let receipt = SalaryReceipt(year: 2026, month: 11, amount: Cents(600_000),
                                    confirmedAt: date(hour: 10))
        let paid = space(salary: Cents(620_000), receipts: [receipt])
        let november = MonthSummary(space: paid, calendar: MonthCalendar(date: date(hour: 9), timeZone: saoPaulo))
        XCTAssertEqual(november.salary, .received(receipt))
        XCTAssertEqual(november.totals.income, Cents(600_000), "Vale o valor confirmado")
        XCTAssertEqual(november.totals.forecastIncome, .zero)
        XCTAssertEqual(november.totals.availablePercent, 100)
        XCTAssertEqual(november.accountsBalance, 705_050)

        let december = MonthSummary(space: paid, calendar: MonthCalendar(date: date(month: 12, hour: 9), timeZone: saoPaulo))
        XCTAssertEqual(december.salary, .pending(Cents(620_000)), "Novo mês, novo previsto")
        XCTAssertEqual(december.totals.income, .zero)
        XCTAssertEqual(december.accountsBalance, 705_050, "O que entrou continua nas contas")
    }

    func testNoSalaryAndZeroSalaryAreTheSame() {
        let calendar = MonthCalendar(date: date(hour: 9), timeZone: saoPaulo)
        XCTAssertNil(MonthSummary(space: space(salary: nil), calendar: calendar).salary)
        XCTAssertNil(MonthSummary(space: space(salary: .zero), calendar: calendar).salary)
        XCTAssertEqual(MonthSummary(space: space(salary: nil), calendar: calendar).totals, .zero)
    }

    // MARK: Registros

    private let checking = Account(kind: .checking, name: "Conta Aurora", initialBalance: Cents(100_000))
    private let aurora = CreditCard(name: "Aurora", closingDay: 3, dueDay: 10)

    private func recordsSpace(_ records: [Record], salary: Cents? = nil,
                              receipts: [SalaryReceipt] = []) -> ConfiguredSpace {
        ConfiguredSpace(profile: Profile(name: "Diuli Vargas", goals: []), accounts: [checking], cards: [aurora],
                        completedAt: Date(timeIntervalSince1970: 0), monthlySalary: salary,
                        salaryReceipts: receipts, records: records)
    }

    private func record(_ kind: RecordKind = .expense, _ cents: Int64, _ description: String = "",
                        category: RecordCategory? = .market, card: Bool = false, installments: Int = 1,
                        month: Int = 11, day: Int = 5, savedHour: Int = 9) -> Record {
        Record(kind: kind, amount: Cents(cents), description: description,
               category: kind == .income ? nil : category,
               source: card ? .card(id: aurora.id) : .account(id: checking.id),
               day: CalendarDay(year: 2026, month: month, day: day), installments: installments,
               savedAt: date(month: month, day: day, hour: savedHour))
    }

    private func summary(_ space: ConfiguredSpace, month: Int = 11, day: Int = 6) -> MonthSummary {
        MonthSummary(space: space, calendar: MonthCalendar(date: date(month: month, day: day, hour: 12), timeZone: saoPaulo))
    }

    func testAccountExpenseAndIncomeEnterTheMonthAndAccounts() {
        let result = summary(recordsSpace([record(.expense, 4_290, "Mercado"), record(.income, 115_000, "Freela · site")]))
        XCTAssertEqual(result.totals.expenses, Cents(4_290))
        XCTAssertEqual(result.totals.income, Cents(115_000))
        XCTAssertEqual(result.totals.balance, 110_710)
        XCTAssertEqual(result.accountsBalance, 100_000 - 4_290 + 115_000)
        XCTAssertTrue(result.hasRecords)
    }

    func testInitialBalanceIsNeverIncome() {
        let result = summary(recordsSpace([record(.expense, 1_000)]))
        XCTAssertEqual(result.totals.income, .zero)
        XCTAssertEqual(result.totals.balance, -1_000)
    }

    func testAccountsCanGoNegative() {
        let result = summary(recordsSpace([record(.expense, 150_000)]))
        XCTAssertEqual(result.accountsBalance, -50_000)
        XCTAssertEqual(BRL.format(signed: result.accountsBalance), "\u{2212} R$ 500,00")
    }

    func testPreviousMonthRecordOnlyChangesAccounts() {
        let result = summary(recordsSpace([record(.expense, 2_000, month: 10, day: 20)]))
        XCTAssertEqual(result.totals.expenses, .zero)
        XCTAssertEqual(result.accountsBalance, 98_000)
    }

    func testCardPurchaseCountsInstallmentsByMonthAndNotInAccounts() {
        let purchase = record(.expense, 60_000, "Fone", category: .shopping, card: true, installments: 3)
        let space = recordsSpace([purchase])
        let november = summary(space)
        XCTAssertEqual(november.totals.expenses, Cents(20_000))
        XCTAssertEqual(november.accountsBalance, 100_000, "Cartão não mexe nas contas")
        XCTAssertEqual(november.totals.bill, Cents(20_000), "1ª parcela na fatura aberta (fecha 3/12)")
        XCTAssertEqual(november.recent.first?.amount, Cents(60_000), "Recente mostra o total")
        XCTAssertEqual(november.recent.first?.installments, 3)
        XCTAssertEqual(november.recent.first?.sourceName, "Cartão Aurora")

        let december = summary(space, month: 12, day: 10)
        XCTAssertEqual(december.totals.expenses, Cents(20_000), "2ª parcela no mês seguinte")
        XCTAssertEqual(december.totals.bill, Cents(20_000), "2ª parcela na fatura que fecha em janeiro")
        XCTAssertEqual(summary(space, month: 12, day: 2).totals.bill, Cents(20_000))
    }

    func testCardRestGoesToTheFirstInstallment() {
        let result = summary(recordsSpace([record(.expense, 10_000, card: true, installments: 3)]))
        XCTAssertEqual(result.totals.expenses, Cents(3_334))
    }

    func testExpenseBreakdownSortedWithTiesInDesignOrder() {
        let result = summary(recordsSpace([
            record(.expense, 1_000, category: .leisure), record(.expense, 3_000, category: .health),
            record(.expense, 1_000, category: .market), record(.expense, 1_000, category: .transport),
        ]))
        XCTAssertEqual(result.expenseBreakdown.map(\.category), [.health, .market, .transport, .leisure])
        XCTAssertEqual(result.expenseBreakdown.map(\.percent), [50, 17, 17, 17])
    }

    func testIncomeBreakdownGroupsByNameWithSalary() {
        let receipt = SalaryReceipt(year: 2026, month: 11, amount: Cents(620_000), confirmedAt: date(day: 5, hour: 10))
        let result = summary(recordsSpace([record(.income, 50_000, "Freela"), record(.income, 65_000, "Freela"),
                                           record(.income, 1_000)],
                                          salary: Cents(620_000), receipts: [receipt]))
        XCTAssertEqual(result.incomeBreakdown.map(\.name), ["Salário", "Freela", "Receita"])
        XCTAssertEqual(result.incomeBreakdown.map(\.amount), [Cents(620_000), Cents(115_000), Cents(1_000)])
        XCTAssertEqual(result.totals.income, Cents(736_000))
    }

    func testRecentOrderLimitAndSalary() {
        let receipt = SalaryReceipt(year: 2026, month: 11, amount: Cents(620_000), confirmedAt: date(day: 4, hour: 10))
        let records = [
            record(.expense, 100, "a", day: 1), record(.expense, 200, "b", day: 2),
            record(.expense, 300, "c", day: 3, savedHour: 8), record(.expense, 400, "d", day: 3, savedHour: 11),
            record(.expense, 500, "e", day: 5), record(.expense, 600, "f", month: 10, day: 30),
        ]
        let result = summary(recordsSpace(records, salary: Cents(620_000), receipts: [receipt]))
        XCTAssertEqual(result.recent.map(\.name), ["e", "Salário", "d", "c", "b"])
        XCTAssertTrue(result.recent[1].isSalary)
        XCTAssertNil(result.recent[1].sourceName)
    }

    func testRecordsOfMissingSourcesAreIgnored() {
        let orphan = Record(kind: .expense, amount: Cents(9_999), description: "", category: .other,
                            source: .account(id: UUID()), day: CalendarDay(year: 2026, month: 11, day: 5),
                            savedAt: date(day: 5, hour: 9))
        let result = summary(recordsSpace([orphan]))
        XCTAssertEqual(result.totals.expenses, .zero)
        XCTAssertEqual(result.accountsBalance, 100_000)
        XCTAssertNil(result.recent.first?.sourceName)
    }
}

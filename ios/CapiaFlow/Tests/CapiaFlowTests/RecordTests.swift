import CapiaFlow
import Foundation
import XCTest

final class RecordTests: XCTestCase {
    private let account = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let card = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    private let day = CalendarDay(year: 2026, month: 11, day: 5)
    private let saved = Date(timeIntervalSince1970: 1_793_000_000)

    private func expense(_ cents: Int64 = 4_290, description: String = "Mercado",
                         category: RecordCategory? = .market, card useCard: Bool = false,
                         installments: Int = 1) -> Record {
        Record(kind: .expense, amount: Cents(cents), description: description, category: category,
               source: useCard ? .card(id: card) : .account(id: account), day: day,
               installments: installments, savedAt: saved)
    }

    func testAmountLimits() {
        XCTAssertFalse(expense(0).isValid)
        XCTAssertTrue(expense(1).isValid)
        XCTAssertTrue(expense(99_999_999).isValid, "R$ 999.999,99")
        XCTAssertFalse(expense(100_000_000).isValid)
    }

    func testDescriptionIsTrimmedAndLimited() {
        XCTAssertEqual(expense(description: "  café  ").description, "café")
        let long = String(repeating: "a", count: 80)
        XCTAssertEqual(expense(description: long).description.count, 60)
    }

    func testDisplayName() {
        XCTAssertEqual(expense(description: "Feira").displayName, "Feira")
        XCTAssertEqual(expense(description: "  ", category: .health).displayName, "Saúde")
        let income = Record(kind: .income, amount: Cents(1_000), description: "", category: .market,
                            source: .account(id: account), day: day, savedAt: saved)
        XCTAssertEqual(income.displayName, "Receita")
        XCTAssertNil(income.category, "Receita não tem categoria")
    }

    func testExpenseNeedsCategoryAndIncomeCannotUseCard() {
        XCTAssertFalse(expense(category: nil).isValid)
        let cardIncome = Record(kind: .income, amount: Cents(1_000), description: "", category: nil,
                                source: .card(id: card), day: day, savedAt: saved)
        XCTAssertFalse(cardIncome.isValid)
    }

    func testInstallmentsOnlyOnCardExpenses() {
        XCTAssertTrue(expense(card: true, installments: 12).isValid)
        XCTAssertFalse(expense(card: true, installments: 13).isValid)
        XCTAssertFalse(expense(card: true, installments: 0).isValid)
        XCTAssertFalse(expense(card: false, installments: 2).isValid, "Conta não parcela")
    }

    func testEachSuggestionRule() {
        let cases: [(String, RecordCategory)] = [
            ("mercado do bairro", .market), ("Feira livre", .market), ("Hortifruti", .market), ("sacolão", .market),
            ("Café Brasa", .restaurants), ("restaurante", .restaurants), ("Padaria", .restaurants),
            ("lanche", .restaurants), ("almoço", .restaurants), ("jantar", .restaurants),
            ("pizza", .restaurants), ("iFood", .restaurants),
            ("Uber", .transport), ("99 pop", .transport), ("ônibus", .transport), ("metrô", .transport),
            ("Posto Ipê", .transport), ("gasolina", .transport), ("combustível", .transport),
            ("Farmácia Vida", .health), ("médico", .health), ("consulta", .health), ("dentista", .health),
            ("aluguel", .home), ("conta de luz", .home), ("água", .home), ("internet", .home), ("condomínio", .home),
            ("cinema", .leisure), ("show", .leisure), ("Streaming Lumen", .leisure), ("bar do Zé", .leisure),
            ("viagem", .leisure), ("jogo", .leisure),
            ("Loja Kaze", .shopping), ("roupa", .shopping), ("tênis", .shopping), ("livro", .shopping),
        ]
        for (text, category) in cases {
            XCTAssertEqual(RecordCategory.suggestion(for: text), category, text)
        }
    }

    func testSuggestionIgnoresCaseAndAccents() {
        XCTAssertEqual(RecordCategory.suggestion(for: "CAFÉ"), .restaurants)
        XCTAssertEqual(RecordCategory.suggestion(for: "cafe"), .restaurants)
        XCTAssertEqual(RecordCategory.suggestion(for: "FARMACIA"), .health)
    }

    func testFragmentsMatchInsideWords() {
        XCTAssertEqual(RecordCategory.suggestion(for: "Supermercado Sol Nascente"), .market)
        XCTAssertEqual(RecordCategory.suggestion(for: "hipermercado"), .market)
        XCTAssertEqual(RecordCategory.suggestion(for: "Cafeteria"), .restaurants)
        XCTAssertEqual(RecordCategory.suggestion(for: "medicamento"), .health)
        XCTAssertEqual(RecordCategory.suggestion(for: "mensalidade do streaming"), .leisure)
    }

    func testShortWordsMatchOnlyWhole() {
        XCTAssertNil(RecordCategory.suggestion(for: "barato"), "\"bar\" só como palavra inteira")
        XCTAssertNil(RecordCategory.suggestion(for: "reluz"))
        XCTAssertNil(RecordCategory.suggestion(for: "1999"))
        XCTAssertNil(RecordCategory.suggestion(for: "PAG*XYZ 8812"))
        XCTAssertNil(RecordCategory.suggestion(for: ""))
    }

    func testFirstRuleWinsWhenSeveralMatch() {
        XCTAssertEqual(RecordCategory.suggestion(for: "café no mercado"), .market, "Mercado vem antes no quadro")
    }

    func testTodayAndYesterdayFollowTheTimeZone() {
        // 6/11/2026 01:30 em UTC é 5/11 22:30 em São Paulo.
        let instant = Date(timeIntervalSince1970: 1_793_928_600)
        let saoPaulo = TimeZone(identifier: "America/Sao_Paulo")!
        let utc = TimeZone(identifier: "UTC")!
        XCTAssertEqual(CalendarDay.today(now: instant, timeZone: utc), CalendarDay(year: 2026, month: 11, day: 6))
        XCTAssertEqual(CalendarDay.today(now: instant, timeZone: saoPaulo), CalendarDay(year: 2026, month: 11, day: 5))
        XCTAssertEqual(CalendarDay.yesterday(now: instant, timeZone: saoPaulo), CalendarDay(year: 2026, month: 11, day: 4))
    }

    func testYesterdayCrossesMonthAndYear() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let newYear = calendar.date(from: DateComponents(year: 2027, month: 1, day: 1, hour: 10))!
        XCTAssertEqual(CalendarDay.yesterday(now: newYear, timeZone: calendar.timeZone),
                       CalendarDay(year: 2026, month: 12, day: 31))
    }

    func testCalendarDayOrderAndText() {
        XCTAssertLessThan(CalendarDay(year: 2026, month: 10, day: 31), day)
        XCTAssertEqual(day.dayMonthText, "05/11")
        XCTAssertEqual(YearMonth(year: 2026, month: 11).adding(months: 3), YearMonth(year: 2027, month: 2))
        XCTAssertEqual(YearMonth(year: 2028, month: 2).dayCount, 29)
        XCTAssertEqual(YearMonth(year: 2100, month: 2).dayCount, 28)
    }
}

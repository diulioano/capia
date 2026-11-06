import CapiaFlow
import XCTest

final class MoneyTests: XCTestCase {
    func testBrazilianFormat() {
        XCTAssertEqual(BRL.format(.zero), "R$ 0,00")
        XCTAssertEqual(BRL.format(Cents(5)), "R$ 0,05")
        XCTAssertEqual(BRL.format(Cents(100)), "R$ 1,00")
        XCTAssertEqual(BRL.format(Cents(123_456)), "R$ 1.234,56")
        XCTAssertEqual(BRL.format(Cents(100_000_000)), "R$ 1.000.000,00")
        XCTAssertEqual(BRL.format(.max), "R$ 999.999.999,99")
    }

    func testShortcutLabelsDropCents() {
        XCTAssertEqual(SetupDraft.balanceShortcutsInReais.map(BRL.shortcutLabel(reais:)),
                       ["+ R$ 500", "+ R$ 1.000", "+ R$ 2.500"])
    }

    func testEditingWorksLikeACalculator() {
        // Digitar 1, 2, 3, 4, 5 vai formatando: 0,01 → 0,12 → 1,23 → 12,34 → 123,45.
        var cents = Cents.zero
        var shown: [String] = []
        for key in ["1", "2", "3", "4", "5"] {
            cents = cents.editing(insert: key)
            shown.append(BRL.format(cents))
        }
        XCTAssertEqual(shown, ["R$ 0,01", "R$ 0,12", "R$ 1,23", "R$ 12,34", "R$ 123,45"])
        // Apagar remove o último algarismo.
        XCTAssertEqual(cents.editing(insert: ""), Cents(1_234))
        XCTAssertEqual(Cents(5).editing(insert: ""), .zero)
        XCTAssertEqual(Cents.zero.editing(insert: ""), .zero)
        // Selecionar tudo e apagar zera; selecionar tudo e digitar substitui.
        XCTAssertEqual(cents.editing(insert: "", replacingAll: true), .zero)
        XCTAssertEqual(cents.editing(insert: "7", replacingAll: true), Cents(7))
        // Depois de um atalho (R$ 1.000,00), digitar continua pela direita.
        XCTAssertEqual(Cents(reais: 1_000).editing(insert: "1"), Cents(1_000_001))
        // Colar texto formatado acrescenta só os algarismos.
        XCTAssertEqual(Cents.zero.editing(insert: "R$ 12,50"), Cents(1_250))
        // Texto sem algarismos não altera; acima de onze algarismos, ignora o excesso.
        XCTAssertEqual(Cents(42).editing(insert: "a"), Cents(42))
        XCTAssertEqual(Cents.max.editing(insert: "1"), .max)
        XCTAssertEqual(Cents(12_345_678_901).editing(insert: "9"), Cents(12_345_678_901))
    }

    func testTypedDigitsFillFromTheRight() {
        XCTAssertEqual(Cents(typed: ""), .zero)
        XCTAssertEqual(Cents(typed: "1"), Cents(1))
        XCTAssertEqual(Cents(typed: "123456"), Cents(123_456))
        // Texto já formatado mais um algarismo, como o campo envia ao digitar.
        XCTAssertEqual(Cents(typed: "R$ 1.234,567"), Cents(1_234_567))
        // Apagar o último algarismo do texto formatado.
        XCTAssertEqual(Cents(typed: "R$ 1.234,5"), Cents(12_345))
        XCTAssertEqual(Cents(typed: "R$ 0,00"), .zero)
        XCTAssertEqual(Cents(typed: "00042"), Cents(42))
        XCTAssertEqual(Cents(typed: "-5a٣7"), Cents(57))
    }

    func testTypedDigitsAreLimitedToElevenDigits() {
        XCTAssertEqual(Cents(typed: "123456789012345"), Cents(12_345_678_901))
        XCTAssertEqual(Cents(typed: "99999999999"), .max)
    }

    func testSumsAreExactAndSaturate() {
        var draft = SetupDraft()
        draft.balance = Cents(typed: "1999")
        for reais in SetupDraft.balanceShortcutsInReais { draft.addToBalance(reais: reais) }
        XCTAssertEqual(draft.balance, Cents(401_999))
        XCTAssertEqual(BRL.format(draft.balance), "R$ 4.019,99")
        draft.balance = Cents(99_999_999_000)
        draft.addToBalance(reais: 2_500)
        XCTAssertEqual(draft.balance, .max)
        XCTAssertEqual(Cents(-1), .zero)
    }

    func testCodingRejectsOutOfRangeValues() throws {
        let data = try JSONEncoder().encode([Cents(123)])
        XCTAssertEqual(try JSONDecoder().decode([Cents].self, from: data), [Cents(123)])
        XCTAssertThrowsError(try JSONDecoder().decode([Cents].self, from: Data("[-1]".utf8)))
        XCTAssertThrowsError(try JSONDecoder().decode([Cents].self, from: Data("[100000000000]".utf8)))
    }

    func testSignedFormatUsesMinusSignAndNeverSignsZero() {
        XCTAssertEqual(BRL.format(signed: 0), "R$ 0,00")
        XCTAssertEqual(BRL.format(signed: 2_350), "R$ 23,50")
        XCTAssertEqual(BRL.format(signed: -2_350), "\u{2212} R$ 23,50")
        XCTAssertEqual(BRL.format(signed: -123_456_78), "\u{2212} R$ 123.456,78")
        XCTAssertEqual(BRL.format(signed: .min), "\u{2212} R$ 999.999.999,99")
        XCTAssertEqual(BRL.format(signed: .max), "R$ 999.999.999,99")
    }

    func testHiddenValueRevealsNoDigits() {
        XCTAssertEqual(BRL.hidden, "R$ ••••")
        XCTAssertFalse(BRL.hidden.contains { $0.isNumber })
    }
}

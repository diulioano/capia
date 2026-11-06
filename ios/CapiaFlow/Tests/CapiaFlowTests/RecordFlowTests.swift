@testable import CapiaFlow
import Foundation
import XCTest

final class RecordFlowTests: XCTestCase {
    private let utc = TimeZone(identifier: "UTC")!
    /// 6/11/2026 12:00 UTC.
    private let now = Date(timeIntervalSince1970: 1_793_966_400)
    private let checking = Account(kind: .checking, name: "Conta Aurora", initialBalance: Cents(100_000))
    private let wallet = Account(kind: .wallet, name: "Carteira", initialBalance: .zero)
    private let aurora = CreditCard(name: "Aurora", closingDay: 3, dueDay: 10)

    private func flow(cards: Bool = true) -> RecordFlow {
        RecordFlow(accounts: [checking, wallet], cards: cards ? [aurora] : [])
    }

    private func typed(_ keys: [PadKey], into flow: inout RecordFlow) {
        keys.forEach { flow.send(.press($0)) }
    }

    private func atDetails(_ cents: [Int] = [4, 2, 9, 0]) -> RecordFlow {
        var flow = flow()
        typed(cents.map { .digit($0) }, into: &flow)
        flow.send(.continueToDetails)
        return flow
    }

    func testInitialState() {
        let flow = flow()
        XCTAssertEqual(flow.mode, .type)
        XCTAssertEqual(flow.phase, .amount)
        XCTAssertEqual(flow.draft.kind, .expense)
        XCTAssertEqual(flow.draft.amount, .zero)
        XCTAssertEqual(flow.draft.source, .account(id: checking.id), "Primeira conta selecionada")
        XCTAssertEqual(flow.draft.date, .today)
        XCTAssertFalse(flow.canContinue)
        XCTAssertNil(flow.toast)
    }

    func testPadWorksLikeACashRegister() {
        var flow = flow()
        typed([.digit(4), .digit(2), .digit(9), .digit(0)], into: &flow)
        XCTAssertEqual(flow.draft.amount, Cents(4_290))
        flow.send(.press(.delete))
        XCTAssertEqual(flow.draft.amount, Cents(429))
        flow.send(.press(.digit(0)))
        flow.send(.press(.doubleZero))
        XCTAssertEqual(flow.draft.amount, Cents(429_000))
    }

    func testPadIgnoresKeysBeyondTheLimit() {
        var flow = flow()
        typed(Array(repeating: .digit(9), count: 8), into: &flow)
        XCTAssertEqual(flow.draft.amount, Record.maxAmount)
        flow.send(.press(.digit(1)))
        flow.send(.press(.doubleZero))
        XCTAssertEqual(flow.draft.amount, Record.maxAmount)
    }

    func testContinueNeedsAnAmountAndBackPreservesIt() {
        var flow = flow()
        flow.send(.continueToDetails)
        XCTAssertEqual(flow.phase, .amount)
        flow.send(.press(.digit(5)))
        flow.send(.continueToDetails)
        XCTAssertEqual(flow.phase, .details)
        flow.send(.back)
        XCTAssertEqual(flow.phase, .amount)
        XCTAssertEqual(flow.draft.amount, Cents(5))
    }

    func testSuggestionNeverOverridesAChoice() {
        var flow = atDetails()
        XCTAssertFalse(flow.canSave, "Gasto sem categoria")
        flow.send(.setDescription("mercado do bairro"))
        XCTAssertEqual(flow.suggestedCategory, .market)
        XCTAssertEqual(flow.effectiveCategory, .market)
        XCTAssertTrue(flow.canSave)
        flow.send(.chooseCategory(.leisure))
        XCTAssertNil(flow.suggestedCategory)
        flow.send(.setDescription("farmácia"))
        XCTAssertEqual(flow.effectiveCategory, .leisure)
    }

    func testZeroAmountInDetailsBlocksSaving() {
        var flow = atDetails()
        flow.send(.chooseCategory(.market))
        flow.send(.setAmount(.zero))
        XCTAssertFalse(flow.canSave)
        flow.send(.setAmount(Cents(200_000_000)))
        XCTAssertEqual(flow.draft.amount, Record.maxAmount)
    }

    func testIncomeHasOnlyAccountsAndNoCategory() {
        var flow = flow()
        flow.send(.selectKind(.income))
        typed([.digit(1)], into: &flow)
        flow.send(.continueToDetails)
        XCTAssertTrue(flow.canSave, "Receita não pede categoria")
        XCTAssertEqual(flow.availableSources, [.account(id: checking.id), .account(id: wallet.id)])
        flow.send(.chooseSource(.card(id: aurora.id)))
        XCTAssertEqual(flow.draft.source, .account(id: checking.id))
        flow.send(.chooseCategory(.market))
        XCTAssertNil(flow.draft.chosenCategory)
        XCTAssertFalse(flow.showsInstallments)
    }

    func testSwitchingKindKeepsTheAmount() {
        var flow = flow()
        typed([.digit(7)], into: &flow)
        flow.send(.selectKind(.income))
        flow.send(.selectKind(.expense))
        XCTAssertEqual(flow.draft.amount, Cents(7))
        XCTAssertEqual(flow.draft.kind, .expense)
    }

    func testInstallmentsOnlyOnCardAndResetOnAccount() {
        var flow = atDetails()
        flow.send(.stepInstallments(1))
        XCTAssertEqual(flow.draft.installments, 1, "Conta não parcela")
        flow.send(.chooseSource(.card(id: aurora.id)))
        XCTAssertTrue(flow.showsInstallments)
        XCTAssertEqual(flow.selectedCard, aurora)
        for _ in 0..<20 { flow.send(.stepInstallments(1)) }
        XCTAssertEqual(flow.draft.installments, 12)
        for _ in 0..<20 { flow.send(.stepInstallments(-1)) }
        XCTAssertEqual(flow.draft.installments, 1)
        flow.send(.stepInstallments(2))
        flow.send(.chooseSource(.account(id: wallet.id)))
        XCTAssertEqual(flow.draft.installments, 1)
        XCTAssertFalse(flow.showsInstallments)
    }

    func testNoCardsMeansOnlyAccounts() {
        XCTAssertEqual(flow(cards: false).availableSources, [.account(id: checking.id), .account(id: wallet.id)])
    }

    func testModeChangeKeepsKindAndAmount() {
        var flow = flow()
        flow.send(.selectKind(.income))
        typed([.digit(3)], into: &flow)
        flow.send(.selectMode(.speak))
        flow.send(.press(.digit(9)))
        XCTAssertEqual(flow.draft.amount, Cents(3), "Teclado inativo fora de Digitar")
        flow.send(.selectMode(.photo))
        flow.send(.selectMode(.type))
        XCTAssertEqual(flow.draft.kind, .income)
        XCTAssertEqual(flow.draft.amount, Cents(3))
    }

    func testMakeRecordResolvesDates() throws {
        var flow = atDetails()
        flow.send(.setDescription("  Mercado  "))
        let today = try XCTUnwrap(flow.makeRecord(now: now, timeZone: utc))
        XCTAssertEqual(today.day, CalendarDay(year: 2026, month: 11, day: 6))
        XCTAssertEqual(today.description, "Mercado")
        XCTAssertEqual(today.category, .market)
        XCTAssertEqual(today.amount, Cents(4_290))
        XCTAssertEqual(today.savedAt, now)

        flow.send(.chooseDate(.yesterday))
        XCTAssertEqual(flow.makeRecord(now: now, timeZone: utc)?.day, CalendarDay(year: 2026, month: 11, day: 5))
        flow.send(.chooseDate(.other(CalendarDay(year: 2026, month: 10, day: 20))))
        XCTAssertEqual(flow.makeRecord(now: now, timeZone: utc)?.day, CalendarDay(year: 2026, month: 10, day: 20))
        flow.send(.chooseDate(.other(CalendarDay(year: 2026, month: 11, day: 7))))
        XCTAssertNil(flow.makeRecord(now: now, timeZone: utc), "Data futura não é aceita")
    }

    func testMakeRecordKeepsInstallmentsOnlyOnCard() throws {
        var flow = atDetails([6, 0, 0, 0, 0])
        flow.send(.chooseCategory(.shopping))
        flow.send(.chooseSource(.card(id: aurora.id)))
        flow.send(.stepInstallments(2))
        let record = try XCTUnwrap(flow.makeRecord(now: now, timeZone: utc))
        XCTAssertEqual(record.installments, 3)
        XCTAssertEqual(record.source, .card(id: aurora.id))
    }

    func testDidSaveResetsAndUndoRestores() throws {
        var flow = atDetails()
        flow.send(.chooseCategory(.market))
        let before = flow.draft
        let record = try XCTUnwrap(flow.makeRecord(now: now, timeZone: utc))
        flow.didSave(record)
        XCTAssertEqual(flow.phase, .amount)
        XCTAssertEqual(flow.draft.amount, .zero)
        XCTAssertEqual(flow.draft.kind, .expense)
        XCTAssertEqual(flow.toast, SavedToast(record: record, previous: before))
        XCTAssertFalse(flow.canSave, "Toque repetido em Salvar não grava de novo")

        flow.undo()
        XCTAssertEqual(flow.draft, before)
        XCTAssertEqual(flow.phase, .details)
        XCTAssertNil(flow.toast)
    }

    func testSaveFailureKeepsTheForm() {
        var flow = atDetails()
        flow.send(.chooseCategory(.market))
        let before = flow
        flow.saveDidFail()
        XCTAssertTrue(flow.saveFailed)
        XCTAssertEqual(flow.draft, before.draft)
        XCTAssertEqual(flow.phase, .details)
    }

    func testDismissToast() throws {
        var flow = atDetails()
        flow.send(.chooseCategory(.market))
        flow.didSave(try XCTUnwrap(flow.makeRecord(now: now, timeZone: utc)))
        flow.send(.dismissToast)
        XCTAssertNil(flow.toast)
    }
}

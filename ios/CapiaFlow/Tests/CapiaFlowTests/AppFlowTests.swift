import CapiaFlow
import Foundation
import XCTest

final class AppFlowTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_793_000_000)

    private func setupStep(_ app: AppFlow) -> SetupStep? {
        if case .setup(let step) = app.screen { return step }
        return nil
    }

    private func next(_ app: inout AppFlow) -> ConfiguredSpace? {
        guard let step = setupStep(app) else { return nil }
        return app.send(.init(.continueStep, from: step), now: now)
    }

    /// Da apresentação até a pergunta do cartão, sem gravar nada.
    private func appAtCardQuestion() -> AppFlow {
        var app = AppFlow(saved: nil)
        app.send(.init(.start, from: .welcome))
        app.send(.init(.skip, from: .introduction(.register)))
        XCTAssertEqual(app.screen, .setup(.name))
        app.editDraft { $0.name = "Diuli" }
        XCTAssertNil(next(&app))
        app.editDraft { $0.toggle(.understandSpending) }
        XCTAssertNil(next(&app))
        app.editDraft { $0.accountName = "Banco Aurora" }
        XCTAssertNil(next(&app))
        app.editDraft { $0.balance = Cents(10_000) }
        XCTAssertNil(next(&app))
        XCTAssertEqual(app.screen, .setup(.salary))
        XCTAssertNil(next(&app))
        XCTAssertEqual(app.screen, .setup(.cardQuestion))
        return app
    }

    func testFreshInstallOpensWelcome() {
        XCTAssertEqual(AppFlow(saved: nil).screen, .getStarted(.welcome))
    }

    func testSkipAndConfigureOpenSetupAndBackReturnsToOrigin() {
        var app = AppFlow(saved: nil)
        app.send(.init(.start, from: .welcome))
        app.send(.init(.continueIntroduction, from: .introduction(.register)))
        app.send(.init(.skip, from: .introduction(.monthlyOverview)))
        XCTAssertEqual(app.screen, .setup(.name))
        app.editDraft { $0.name = "Partial" }
        XCTAssertNil(app.send(.init(.back, from: .name)))
        XCTAssertEqual(app.screen, .getStarted(.introduction(.monthlyOverview)))
        XCTAssertNil(app.setup)

        app.send(.init(.continueIntroduction, from: .introduction(.monthlyOverview)))
        app.send(.init(.configure, from: .introduction(.goals)))
        XCTAssertEqual(app.screen, .setup(.name))
        XCTAssertEqual(app.setup?.draft.name, "", "Nova entrada começa sem rascunho")
    }

    func testReachingDoneProducesSpaceToSave() {
        var app = appAtCardQuestion()
        app.editDraft { $0.hasCard = true }
        XCTAssertNil(next(&app))
        let space = next(&app)
        XCTAssertEqual(app.screen, .setup(.done))
        XCTAssertEqual(space?.accounts.map(\.name), ["Banco Aurora"])
        XCTAssertEqual(space?.cards.map(\.closingDay), [3])
        XCTAssertEqual(space?.completedAt, now)
        XCTAssertEqual(app.currentSpace(now: now), space)
    }

    func testInterruptedSetupNeverProducesSpace() {
        var app = appAtCardQuestion()
        XCTAssertNil(app.currentSpace(now: now))
        XCTAssertNil(app.send(.init(.back, from: .cardQuestion), now: now))
    }

    func testRepeatingDoneAfterAnotherAccountSavesAgain() {
        var app = appAtCardQuestion()
        app.editDraft { $0.hasCard = false }
        XCTAssertNotNil(next(&app))
        XCTAssertNil(app.send(.init(.addAnotherAccount, from: .done), now: now))
        app.editDraft { $0.accountKind = .wallet }
        XCTAssertNil(next(&app))
        XCTAssertNil(next(&app))
        app.editDraft { $0.hasCard = false }
        let space = next(&app)
        XCTAssertEqual(space?.accounts.map(\.name), ["Banco Aurora", "Carteira"])
    }

    func testViewMonthOpensHomeOnMonthTab() {
        var app = appAtCardQuestion()
        app.editDraft { $0.hasCard = false }
        let saved = next(&app)
        XCTAssertNil(app.send(.init(.viewMonth, from: .done), now: now))
        XCTAssertEqual(app.screen, .home(.month))
        XCTAssertEqual(app.space, saved)
        app.editDraft { $0.accountName = "Ignored" }
        XCTAssertEqual(app.setup?.draft.accountName, "Banco Aurora")
        XCTAssertNil(app.send(.init(.back, from: .done), now: now), "Sem conclusão visível, nada muda")
        XCTAssertEqual(app.screen, .home(.month))
    }

    func testSavedSpaceOpensHomeAndIgnoresGetStarted() {
        var app = AppFlow(saved: savedSpace)
        XCTAssertEqual(app.screen, .home(.month))
        XCTAssertEqual(app.space, savedSpace)
        app.send(.init(.start, from: .welcome))
        XCTAssertEqual(app.screen, .home(.month))
    }

    func testHomeActionsChangeTabsOnlyInsideHome() {
        var app = AppFlow(saved: nil)
        app.send(.select(.goals))
        XCTAssertEqual(app.screen, .getStarted(.welcome))
        XCTAssertEqual(app.home, HomeFlow())

        app = AppFlow(saved: savedSpace)
        app.send(.select(.goals))
        XCTAssertEqual(app.screen, .home(.goals))
        app.send(.openBill)
        XCTAssertEqual(app.screen, .home(.accounts))
        app.send(.select(.month))
        XCTAssertEqual(app.screen, .home(.month))
    }

    func testAnotherAccountFromAccountsTabSavesAndReturnsHome() {
        var app = AppFlow(saved: savedSpace)
        app.addAnotherAccountFromHome()
        XCTAssertEqual(app.screen, .home(.month), "Só a partir da aba Contas")

        app.send(.toggleValuesHidden)
        app.send(.select(.accounts))
        app.addAnotherAccountFromHome()
        XCTAssertEqual(app.screen, .setup(.account))
        app.editDraft { $0.accountKind = .savings; $0.accountName = "Banco Seiva" }
        XCTAssertNil(next(&app))
        XCTAssertNil(next(&app))
        app.editDraft { $0.hasCard = false }
        let space = next(&app)
        XCTAssertEqual(app.screen, .setup(.done))
        XCTAssertEqual(space?.accounts.map(\.name), ["Banco Aurora", "Banco Seiva"])
        XCTAssertEqual(space?.profile, savedSpace.profile)

        app.send(.init(.viewMonth, from: .done), now: now)
        XCTAssertEqual(app.screen, .home(.month))
        XCTAssertEqual(app.space?.accounts.map(\.name), ["Banco Aurora", "Banco Seiva"])
        XCTAssertEqual(app.space?.completedAt, savedSpace.completedAt)
        XCTAssertTrue(app.home.valuesHidden, "Ocultar valores vale para a sessão")
    }

    func testCancellingAnotherAccountKeepsItems() {
        var app = AppFlow(saved: savedSpace)
        app.send(.select(.accounts))
        app.addAnotherAccountFromHome()
        app.send(.init(.back, from: .account), now: now)
        XCTAssertEqual(app.screen, .setup(.done))
        XCTAssertFalse(app.setup?.canGoBack ?? true)
        XCTAssertEqual(app.currentSpace(now: now), savedSpace)
        app.send(.init(.viewMonth, from: .done), now: now)
        XCTAssertEqual(app.screen, .home(.month))
        XCTAssertEqual(app.space, savedSpace)
    }

    private var savedSpace: ConfiguredSpace {
        ConfiguredSpace(
            profile: Profile(name: "Diuli", goals: [.saveForGoal]),
            accounts: [Account(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                               kind: .checking, name: "Banco Aurora", initialBalance: Cents(99))],
            cards: [], completedAt: now)
    }

    func testConfirmSalaryRecordsTheMonthOnceAndSaves() {
        var saved = savedSpace
        saved.monthlySalary = Cents(620_000)
        var app = AppFlow(saved: saved)
        let november = MonthCalendar(date: now, timeZone: TimeZone(identifier: "America/Sao_Paulo")!)
        let space = app.confirmSalary(in: november, now: now)
        XCTAssertEqual(space?.salaryReceipts,
                       [SalaryReceipt(year: november.year, month: november.month, amount: Cents(620_000), confirmedAt: now)])
        XCTAssertEqual(app.space, space)
        XCTAssertNil(app.confirmSalary(in: november, now: now), "Um recebimento por mês")
        XCTAssertEqual(space?.accountsBalance, 620_099)

        let summary = MonthSummary(space: app.space!, calendar: november)
        XCTAssertEqual(summary.totals.income, Cents(620_000))
        XCTAssertEqual(summary.totals.forecastIncome, .zero)

        // A conta adicionada depois preserva o recebimento ao gravar de novo.
        app.send(.select(.accounts))
        app.addAnotherAccountFromHome()
        app.editDraft { $0.accountKind = .wallet }
        _ = next(&app)
        _ = next(&app)
        app.editDraft { $0.hasCard = false }
        let resaved = next(&app)
        XCTAssertEqual(resaved?.salaryReceipts, space?.salaryReceipts)
        XCTAssertEqual(resaved?.monthlySalary, Cents(620_000))
    }

    func testConfirmSalaryNeedsSalaryAndHome() {
        var app = AppFlow(saved: savedSpace)
        let calendar = MonthCalendar(date: now, timeZone: .gmt)
        XCTAssertNil(app.confirmSalary(in: calendar, now: now), "Sem salário informado")
        var withSalary = savedSpace
        withSalary.monthlySalary = Cents(100)
        app = AppFlow(saved: withSalary)
        app.send(.select(.accounts))
        app.addAnotherAccountFromHome()
        XCTAssertNil(app.confirmSalary(in: calendar, now: now), "Fora do Início")
    }

    // MARK: Novo registro

    private var spaceWithCard: ConfiguredSpace {
        var space = savedSpace
        space.cards = [CreditCard(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                                  name: "Banco Aurora", closingDay: 3, dueDay: 10)]
        return space
    }

    private let utc = TimeZone(identifier: "UTC")!

    /// Abre o registro e preenche um gasto de R$ 42,90 em Mercado.
    private func appWithFilledExpense() -> AppFlow {
        var app = AppFlow(saved: spaceWithCard)
        app.send(.openNewRecord)
        [4, 2, 9, 0].forEach { app.send(.press(.digit($0))) }
        app.send(.continueToDetails)
        app.send(.chooseCategory(.market))
        return app
    }

    func testOpeningTheRecordUsesTheSpaceSourcesAndDoesNotStack() {
        var app = AppFlow(saved: spaceWithCard)
        XCTAssertNil(app.record)
        app.send(.openNewRecord)
        app.send(.press(.digit(5)))
        app.send(.openNewRecord)
        XCTAssertEqual(app.record?.draft.amount, Cents(5), "Repetir não recria")
        XCTAssertEqual(app.record?.accounts, spaceWithCard.accounts)
        XCTAssertEqual(app.record?.cards, spaceWithCard.cards)
        XCTAssertEqual(app.screen, .home(.month))
    }

    func testClosingDiscardsWithoutSaving() {
        var app = appWithFilledExpense()
        app.send(.closeNewRecord)
        XCTAssertNil(app.record)
        XCTAssertEqual(app.space?.records, [])
        app.send(.openNewRecord)
        XCTAssertEqual(app.record?.draft.amount, .zero, "Começa do zero")
        app.send(.select(.accounts))
        XCTAssertNil(app.record, "Trocar de aba fecha o registro")
    }

    func testPendingRecordDoesNotChangeTheSessionUntilCommitted() throws {
        var app = appWithFilledExpense()
        let pending = try XCTUnwrap(app.pendingRecord(now: now, timeZone: utc))
        XCTAssertEqual(pending.space.records, [pending.record])
        XCTAssertEqual(app.space?.records, [], "Nada muda antes de gravar")

        app.commitRecord(pending.record)
        XCTAssertEqual(app.space, pending.space)
        XCTAssertEqual(app.record?.draft.amount, .zero)
        XCTAssertEqual(app.record?.toast?.record, pending.record)

        app.commitRecord(pending.record)
        XCTAssertEqual(app.space?.records.count, 1, "O mesmo registro não entra duas vezes")
        XCTAssertNil(app.pendingRecord(now: now, timeZone: utc), "Formulário zerado não salva")
    }

    func testSaveFailureLeavesSpaceAndForm() throws {
        var app = appWithFilledExpense()
        _ = try XCTUnwrap(app.pendingRecord(now: now, timeZone: utc))
        let before = app.record?.draft
        app.recordSaveFailed()
        XCTAssertEqual(app.space?.records, [])
        XCTAssertEqual(app.record?.draft, before)
        XCTAssertEqual(app.record?.saveFailed, true)
        XCTAssertNotNil(app.pendingRecord(now: now, timeZone: utc), "Tentar de novo continua possível")
    }

    func testUndoRemovesTheRecordAndRestoresTheForm() throws {
        var app = appWithFilledExpense()
        let before = app.record?.draft
        let pending = try XCTUnwrap(app.pendingRecord(now: now, timeZone: utc))
        app.commitRecord(pending.record)
        let undone = try XCTUnwrap(app.spaceUndoingLastRecord)
        XCTAssertEqual(undone.records, [])
        XCTAssertEqual(app.space?.records.count, 1, "Só muda depois de gravar o desfazer")
        app.undoLastRecord()
        XCTAssertEqual(app.space?.records, [])
        XCTAssertEqual(app.record?.draft, before)
        XCTAssertEqual(app.record?.phase, .details)
        XCTAssertNil(app.spaceUndoingLastRecord, "Sem aviso, nada a desfazer")
    }

    func testRecordsSurviveAddingAnotherAccount() throws {
        var app = appWithFilledExpense()
        let pending = try XCTUnwrap(app.pendingRecord(now: now, timeZone: utc))
        app.commitRecord(pending.record)
        app.send(.select(.accounts))
        app.addAnotherAccountFromHome()
        app.editDraft { $0.accountKind = .wallet }
        _ = next(&app)
        _ = next(&app)
        app.editDraft { $0.hasCard = false }
        let resaved = try XCTUnwrap(next(&app))
        XCTAssertEqual(resaved.records, [pending.record])
    }

    func testRecordActionsNeedAnOpenRecord() {
        var app = AppFlow(saved: spaceWithCard)
        app.send(.press(.digit(1)))
        XCTAssertNil(app.record)
        XCTAssertNil(app.pendingRecord(now: now, timeZone: utc))
    }
}

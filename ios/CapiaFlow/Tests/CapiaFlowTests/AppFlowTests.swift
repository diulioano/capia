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

    func testMonthAndBackToSummary() {
        var app = appAtCardQuestion()
        app.editDraft { $0.hasCard = false }
        _ = next(&app)
        XCTAssertNil(app.send(.init(.viewMonth, from: .done), now: now))
        XCTAssertEqual(app.screen, .month)
        app.editDraft { $0.accountName = "Ignored" }
        XCTAssertEqual(app.setup?.draft.accountName, "Banco Aurora")
        app.returnFromMonth()
        XCTAssertEqual(app.screen, .setup(.done))
        XCTAssertTrue(app.setup?.canGoBack ?? false)
    }

    func testSavedSpaceOpensMonthAndRestoresSummary() {
        let saved = ConfiguredSpace(
            profile: Profile(name: "Diuli", goals: [.saveForGoal]),
            accounts: [Account(kind: .checking, name: "Banco Aurora", initialBalance: Cents(99))],
            cards: [], completedAt: now)
        var app = AppFlow(saved: saved)
        XCTAssertEqual(app.screen, .month)
        app.send(.init(.start, from: .welcome))
        XCTAssertEqual(app.screen, .month)
        app.returnFromMonth()
        XCTAssertEqual(app.screen, .setup(.done))
        XCTAssertFalse(app.setup?.canGoBack ?? true)
        XCTAssertEqual(app.currentSpace(now: now), saved)

        app.send(.init(.addAnotherAccount, from: .done), now: now)
        XCTAssertEqual(app.screen, .setup(.account))
        app.send(.init(.back, from: .account), now: now)
        XCTAssertEqual(app.screen, .setup(.done))
    }
}

import CapiaFlow
import XCTest

final class SetupFlowTests: XCTestCase {
    private func next(_ flow: inout SetupFlow) {
        flow.send(.init(.continueStep, from: flow.step))
    }

    private func back(_ flow: inout SetupFlow) -> SetupExit? {
        flow.send(.init(.back, from: flow.step))
    }

    /// Avança até a pergunta do cartão com a conta informada.
    private func flowAtCardQuestion(kind: AccountKind = .checking, bank: String = "Banco Aurora",
                                    balance: String = "123456") -> SetupFlow {
        var flow = SetupFlow(origin: .goals)
        flow.draft.name = " Diuli Vargas "
        next(&flow)
        flow.draft.toggle(.understandSpending)
        next(&flow)
        flow.draft.accountKind = kind
        flow.draft.accountName = bank
        next(&flow)
        flow.draft.balance = Cents(typed: balance)
        next(&flow)
        XCTAssertEqual(flow.step, .cardQuestion)
        return flow
    }

    func testJourneyWithCard() {
        var flow = flowAtCardQuestion()
        XCTAssertEqual(flow.draft.greeting, "Diuli")
        flow.draft.hasCard = true
        next(&flow)
        XCTAssertEqual(flow.step, .cardDates)
        XCTAssertEqual(flow.draft.closingDay, 3)
        XCTAssertEqual(flow.draft.dueDay, 10)
        flow.draft.setClosingDay(5)
        flow.draft.setDueDay(12)
        next(&flow)
        XCTAssertEqual(flow.step, .done)
        XCTAssertEqual(flow.accounts.map(\.name), ["Banco Aurora"])
        XCTAssertEqual(flow.accounts.first?.initialBalance, Cents(123_456))
        XCTAssertEqual(flow.accounts.first?.kind, .checking)
        XCTAssertEqual(flow.cards.map(\.name), ["Banco Aurora"])
        XCTAssertEqual(flow.cards.first?.closingDay, 5)
        XCTAssertEqual(flow.cards.first?.dueDay, 12)

        let space = flow.space(completedAt: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(space?.profile, Profile(name: "Diuli Vargas", goals: [.understandSpending]))
        XCTAssertEqual(space?.accounts.count, 1)
        XCTAssertEqual(space?.cards.count, 1)
    }

    func testJourneyWithoutCardSkipsDates() {
        var flow = flowAtCardQuestion()
        flow.draft.hasCard = false
        next(&flow)
        XCTAssertEqual(flow.step, .done)
        XCTAssertEqual(flow.accounts.count, 1)
        XCTAssertTrue(flow.cards.isEmpty)
    }

    func testProgressPositions() {
        XCTAssertEqual(SetupStep.allCases.map(\.position), [1, 2, 3, 4, 5, 6, nil])
    }

    func testContinueRules() {
        var flow = SetupFlow(origin: .register)
        for name in ["", " ", "D", " D "] {
            flow.draft.name = name
            XCTAssertFalse(flow.canContinue, name)
            next(&flow)
            XCTAssertEqual(flow.step, .name)
        }
        flow.draft.name = "D"
        XCTAssertTrue(flow.draft.isNameOneShort)
        flow.draft.name = "Di"
        XCTAssertFalse(flow.draft.isNameOneShort)
        next(&flow)

        XCTAssertFalse(flow.canContinue)
        flow.draft.toggle(.saveForGoal)
        flow.draft.toggle(.leaveSpreadsheet)
        flow.draft.toggle(.saveForGoal)
        XCTAssertEqual(flow.draft.goals, [.leaveSpreadsheet])
        next(&flow)
        XCTAssertEqual(flow.step, .account)

        for kind in [AccountKind.checking, .savings] {
            flow.draft.accountKind = kind
            flow.draft.accountName = " B "
            XCTAssertFalse(flow.canContinue)
            flow.draft.accountName = "Bx"
            XCTAssertTrue(flow.canContinue)
        }
        flow.draft.accountKind = .wallet
        flow.draft.accountName = ""
        XCTAssertTrue(flow.canContinue)
        next(&flow)

        XCTAssertTrue(flow.canContinue, "Saldo zero é aceito")
        next(&flow)

        XCTAssertFalse(flow.canContinue)
        flow.draft.hasCard = true
        next(&flow)
        flow.draft.setDueDay(3)
        XCTAssertFalse(flow.canContinue)
        next(&flow)
        XCTAssertEqual(flow.step, .cardDates)
        flow.draft.setDueDay(32)
        flow.draft.setClosingDay(0)
        XCTAssertEqual(flow.draft.closingDay, 3)
        XCTAssertEqual(flow.draft.dueDay, 3)
        flow.draft.setDueDay(31)
        XCTAssertTrue(flow.canContinue)
    }

    func testWalletWithoutNicknameIsCalledCarteira() {
        var flow = flowAtCardQuestion(kind: .wallet, bank: "  ")
        XCTAssertEqual(flow.draft.accountDisplayName, "Carteira")
        flow.draft.hasCard = true
        next(&flow)
        next(&flow)
        XCTAssertEqual(flow.accounts.first?.name, "Carteira")
        XCTAssertEqual(flow.cards.first?.name, "Carteira")
    }

    func testDisplayNameFallbacks() {
        var draft = SetupDraft()
        XCTAssertEqual(draft.accountDisplayName, "sua conta")
        draft.accountName = "  Nubank "
        XCTAssertEqual(draft.accountDisplayName, "Nubank")
        draft.name = ""
        XCTAssertEqual(draft.greeting, "")
    }

    func testBackFromEveryStepPreservesDraft() {
        var flow = flowAtCardQuestion()
        flow.draft.hasCard = true
        next(&flow)
        flow.draft.setClosingDay(7)
        let draft = flow.draft
        let expected: [SetupStep] = [.cardQuestion, .balance, .account, .goals, .name]
        for step in expected {
            XCTAssertNil(back(&flow))
            XCTAssertEqual(flow.step, step)
            XCTAssertEqual(flow.draft, draft)
        }
        XCTAssertEqual(back(&flow), .introduction(.goals))
        XCTAssertEqual(flow.step, .name)
    }

    func testFirstStepReturnsToEveryOrigin() {
        for origin in IntroStep.allCases {
            var flow = SetupFlow(origin: origin)
            XCTAssertEqual(back(&flow), .introduction(origin))
        }
    }

    func testStaleAndIncompatibleActionsAreIgnored() {
        var flow = SetupFlow(origin: .register)
        flow.draft.name = "Diuli"
        let action = SetupAction(.continueStep, from: .name)
        flow.send(action)
        flow.send(action)
        XCTAssertEqual(flow.step, .goals)
        XCTAssertNil(flow.send(.init(.back, from: .name)))
        XCTAssertNil(flow.send(.init(.viewMonth, from: .goals)))
        flow.send(.init(.addAnotherAccount, from: .goals))
        XCTAssertEqual(flow.step, .goals)
        XCTAssertTrue(flow.accounts.isEmpty)
    }

    func testRepeatedBackAndContinueAtDoneDoNotDuplicate() {
        var flow = flowAtCardQuestion()
        flow.draft.hasCard = true
        next(&flow)
        next(&flow)
        let continueAction = SetupAction(.continueStep, from: .cardDates)
        flow.send(continueAction)
        XCTAssertEqual(flow.accounts.count, 1)
        XCTAssertTrue(flow.canGoBack)

        XCTAssertNil(back(&flow))
        XCTAssertEqual(flow.step, .cardDates)
        XCTAssertTrue(flow.accounts.isEmpty)
        XCTAssertTrue(flow.cards.isEmpty)
        flow.send(continueAction)
        flow.send(continueAction)
        XCTAssertEqual(flow.accounts.count, 1)
        XCTAssertEqual(flow.cards.count, 1)

        var withoutCard = flowAtCardQuestion()
        withoutCard.draft.hasCard = false
        next(&withoutCard)
        _ = back(&withoutCard)
        XCTAssertEqual(withoutCard.step, .cardQuestion)
        XCTAssertTrue(withoutCard.accounts.isEmpty)
    }

    func testAddAnotherAccountAccumulates() {
        var flow = flowAtCardQuestion()
        flow.draft.hasCard = true
        next(&flow)
        next(&flow)
        flow.send(.init(.addAnotherAccount, from: .done))
        XCTAssertEqual(flow.step, .account)
        XCTAssertEqual(flow.mode, .addingAccount)
        XCTAssertEqual(flow.draft.name, " Diuli Vargas ")
        XCTAssertEqual(flow.draft.goals, [.understandSpending])
        XCTAssertEqual(flow.draft.accountName, "")
        XCTAssertEqual(flow.draft.accountKind, .checking)
        XCTAssertEqual(flow.draft.balance, .zero)
        XCTAssertNil(flow.draft.hasCard)
        XCTAssertEqual(flow.draft.closingDay, 3)

        flow.draft.accountKind = .savings
        flow.draft.accountName = "Banco Aurora"
        next(&flow)
        flow.draft.addToBalance(reais: 500)
        next(&flow)
        flow.draft.hasCard = false
        next(&flow)
        XCTAssertEqual(flow.step, .done)
        XCTAssertEqual(flow.accounts.map(\.kind), [.checking, .savings])
        XCTAssertEqual(flow.accounts.map(\.name), ["Banco Aurora", "Banco Aurora"])
        XCTAssertNotEqual(flow.accounts[0].id, flow.accounts[1].id)
        XCTAssertEqual(flow.cards.count, 1)

        // Voltar da segunda conclusão remove somente a segunda conta.
        _ = back(&flow)
        XCTAssertEqual(flow.accounts.count, 1)
        XCTAssertEqual(flow.cards.count, 1)
    }

    func testCancelAnotherAccountReturnsToDoneUnchanged() {
        var flow = flowAtCardQuestion()
        flow.draft.hasCard = false
        next(&flow)
        let accounts = flow.accounts
        flow.send(.init(.addAnotherAccount, from: .done))
        XCTAssertNil(back(&flow))
        XCTAssertEqual(flow.step, .done)
        XCTAssertEqual(flow.accounts, accounts)
        XCTAssertFalse(flow.canGoBack)
        XCTAssertNil(back(&flow))
        XCTAssertEqual(flow.step, .done)
    }

    func testViewMonthExitsOnlyFromDone() {
        var flow = flowAtCardQuestion()
        XCTAssertNil(flow.send(.init(.viewMonth, from: .cardQuestion)))
        flow.draft.hasCard = false
        next(&flow)
        XCTAssertEqual(flow.send(.init(.viewMonth, from: .done)), .month)
        XCTAssertEqual(flow.step, .done)
    }

    func testMoodFollowsStepState() {
        var flow = SetupFlow(origin: .register)
        XCTAssertEqual(flow.mood, .calm)
        flow.draft.name = "D"
        XCTAssertEqual(flow.mood, .thinking)
        flow.draft.name = "Di"
        XCTAssertEqual(flow.mood, .happy)
        next(&flow)
        XCTAssertEqual(flow.mood, .thinking)
        flow.draft.toggle(.saveForGoal)
        XCTAssertEqual(flow.mood, .happy)

        var done = flowAtCardQuestion()
        done.draft.hasCard = false
        next(&done)
        XCTAssertEqual(done.mood, .celebrating)
    }

    func testRestoringOpensDoneWithoutBack() {
        let space = ConfiguredSpace(
            profile: Profile(name: "Diuli", goals: [.organizeCardBills]),
            accounts: [Account(kind: .savings, name: "Banco Aurora", initialBalance: Cents(50_000))],
            cards: [CreditCard(name: "Banco Aurora", closingDay: 5, dueDay: 12)],
            completedAt: Date(timeIntervalSince1970: 0))
        var flow = SetupFlow(restoring: space)
        XCTAssertEqual(flow.step, .done)
        XCTAssertFalse(flow.canGoBack)
        XCTAssertNil(back(&flow))
        XCTAssertEqual(flow.step, .done)
        XCTAssertEqual(flow.draft.greeting, "Diuli")
        XCTAssertEqual(flow.space(completedAt: space.completedAt), space)

        flow.send(.init(.addAnotherAccount, from: .done))
        XCTAssertNil(back(&flow))
        XCTAssertEqual(flow.step, .done)
        XCTAssertEqual(flow.accounts, space.accounts)
    }

    func testNoSpaceBeforeDone() {
        let flow = flowAtCardQuestion()
        XCTAssertNil(flow.space(completedAt: Date()))
    }
}

final class CardDatesTests: XCTestCase {
    func testGapCountsIntoNextMonth() {
        XCTAssertEqual(CreditCard.gap(closingDay: 3, dueDay: 10), 7)
        XCTAssertEqual(CreditCard.gap(closingDay: 25, dueDay: 5), 10)
        XCTAssertEqual(CreditCard.gap(closingDay: 10, dueDay: 3), 23)
        XCTAssertTrue(CreditCard.dueIsNextMonth(closingDay: 25, dueDay: 5))
        XCTAssertFalse(CreditCard.dueIsNextMonth(closingDay: 3, dueDay: 10))
    }

    func testSuggestedDueDayIsSevenDaysLater() {
        XCTAssertEqual(CreditCard.suggestedDueDay(closingDay: 3), 10)
        XCTAssertEqual(CreditCard.suggestedDueDay(closingDay: 24), 31)
        XCTAssertEqual(CreditCard.suggestedDueDay(closingDay: 25), 2)
        XCTAssertEqual(CreditCard.suggestedDueDay(closingDay: 31), 8)
        for day in CreditCard.days {
            let due = CreditCard.suggestedDueDay(closingDay: day)
            XCTAssertTrue(CreditCard.days.contains(due))
            XCTAssertEqual(CreditCard.gap(closingDay: day, dueDay: due), 7)
        }
    }

    func testClosingSuggestsDueUntilDueIsChosen() {
        var draft = SetupDraft()
        draft.setClosingDay(25)
        XCTAssertEqual(draft.dueDay, 2)
        XCTAssertTrue(draft.dueIsNextMonth)
        XCTAssertFalse(draft.isCardGapUnusual)
        draft.setDueDay(5)
        draft.setClosingDay(20)
        XCTAssertEqual(draft.dueDay, 5, "Vencimento escolhido não é sobrescrito")
    }

    func testUnusualGapWarnsWithoutBlocking() {
        var flow = SetupFlow(origin: .register)
        flow.draft.name = "Diuli"
        flow.send(.init(.continueStep, from: .name))
        flow.draft.toggle(.saveForGoal)
        flow.send(.init(.continueStep, from: .goals))
        flow.draft.accountName = "Banco Aurora"
        flow.send(.init(.continueStep, from: .account))
        flow.send(.init(.continueStep, from: .balance))
        flow.draft.hasCard = true
        flow.send(.init(.continueStep, from: .cardQuestion))
        flow.draft.setDueDay(4)
        XCTAssertTrue(flow.draft.isCardGapUnusual, "1 dia")
        XCTAssertTrue(flow.canContinue)
        flow.draft.setClosingDay(10)
        flow.draft.setDueDay(3)
        XCTAssertTrue(flow.draft.isCardGapUnusual, "23 dias")
        flow.draft.setDueDay(20)
        XCTAssertFalse(flow.draft.isCardGapUnusual, "10 dias")
        flow.draft.setDueDay(10)
        XCTAssertFalse(flow.draft.isCardGapUnusual, "Dias iguais são erro, não aviso")
        XCTAssertFalse(flow.canContinue)
    }

    func testAnotherAccountRestoresSuggestion() {
        var flow = SetupFlow(origin: .register)
        flow.draft.name = "Diuli"
        flow.send(.init(.continueStep, from: .name))
        flow.draft.toggle(.saveForGoal)
        flow.send(.init(.continueStep, from: .goals))
        flow.draft.accountName = "Banco Aurora"
        flow.send(.init(.continueStep, from: .account))
        flow.send(.init(.continueStep, from: .balance))
        flow.draft.hasCard = true
        flow.send(.init(.continueStep, from: .cardQuestion))
        flow.draft.setDueDay(20)
        flow.send(.init(.continueStep, from: .cardDates))
        flow.send(.init(.addAnotherAccount, from: .done))
        XCTAssertFalse(flow.draft.dueDayChosen)
        flow.draft.setClosingDay(25)
        XCTAssertEqual(flow.draft.dueDay, 2)
    }
}

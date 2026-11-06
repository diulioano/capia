import CapiaFlow
import XCTest

final class GetStartedFlowTests: XCTestCase {
    private func flow(at step: IntroStep) -> GetStartedFlow {
        var flow = GetStartedFlow()
        flow.send(.init(.start, from: .welcome))
        if step != .register {
            flow.send(.init(.continueIntroduction, from: .introduction(.register)))
        }
        if step == .goals {
            flow.send(.init(.continueIntroduction, from: .introduction(.monthlyOverview)))
        }
        return flow
    }

    func testCompleteJourneyAndReturnFromConfiguration() {
        var flow = GetStartedFlow()
        XCTAssertEqual(flow.screen, .welcome)
        flow.send(.init(.start, from: .welcome))
        XCTAssertEqual(flow.screen, .introduction(.register))
        flow.send(.init(.continueIntroduction, from: flow.screen))
        XCTAssertEqual(flow.screen, .introduction(.monthlyOverview))
        flow.send(.init(.continueIntroduction, from: flow.screen))
        XCTAssertEqual(flow.screen, .introduction(.goals))
        flow.send(.init(.configure, from: flow.screen))
        XCTAssertEqual(flow.screen, .setup(origin: .goals))
        flow.send(.init(.returnFromSetup, from: flow.screen))
        XCTAssertEqual(flow.screen, .introduction(.goals))
    }

    func testEveryBackDestination() {
        let destinations: [(IntroStep, GetStartedScreen)] = [
            (.register, .welcome),
            (.monthlyOverview, .introduction(.register)),
            (.goals, .introduction(.monthlyOverview))
        ]
        for (step, destination) in destinations {
            var flow = flow(at: step)
            flow.send(.init(.back, from: flow.screen))
            XCTAssertEqual(flow.screen, destination)
        }
    }

    func testSkipPreservesEveryOrigin() {
        for step in IntroStep.allCases {
            var flow = flow(at: step)
            flow.send(.init(.skip, from: flow.screen))
            XCTAssertEqual(flow.screen, .setup(origin: step))
            flow.send(.init(.returnFromSetup, from: flow.screen))
            XCTAssertEqual(flow.screen, .introduction(step))
        }
    }

    func testNewSessionAlwaysWelcomes() {
        var previous = flow(at: .goals)
        previous.send(.init(.configure, from: previous.screen))
        XCTAssertEqual(GetStartedFlow().screen, .welcome)
    }

    func testRepeatedActionsFromOldScreenDoNotAdvanceAgain() {
        for step in IntroStep.allCases {
            for intent in GetStartedAction.Intent.allCases {
                var flow = flow(at: step)
                let action = GetStartedAction(intent, from: flow.screen)
                flow.send(action)
                let destination = flow.screen
                flow.send(action)
                XCTAssertEqual(flow.screen, destination)
            }
        }
        var flow = GetStartedFlow()
        let start = GetStartedAction(.start, from: .welcome)
        flow.send(start)
        flow.send(start)
        XCTAssertEqual(flow.screen, .introduction(.register))
    }

    func testIncompatibleActionsAndForeignOriginsAreIgnored() {
        var welcome = GetStartedFlow()
        for intent in GetStartedAction.Intent.allCases where intent != .start {
            welcome.send(.init(intent, from: .welcome))
            XCTAssertEqual(welcome.screen, .welcome)
        }
        for step in IntroStep.allCases {
            var flow = flow(at: step)
            for intent in [GetStartedAction.Intent.start, .returnFromSetup] {
                flow.send(.init(intent, from: flow.screen))
                XCTAssertEqual(flow.screen, .introduction(step))
            }
            if step != .goals {
                flow.send(.init(.configure, from: flow.screen))
                XCTAssertEqual(flow.screen, .introduction(step))
            } else {
                flow.send(.init(.continueIntroduction, from: flow.screen))
                XCTAssertEqual(flow.screen, .introduction(step))
            }
            for intent in GetStartedAction.Intent.allCases {
                flow.send(.init(intent, from: .welcome))
                XCTAssertEqual(flow.screen, .introduction(step))
            }
            flow.send(.init(.skip, from: flow.screen))
            for intent in GetStartedAction.Intent.allCases where intent != .returnFromSetup {
                flow.send(.init(intent, from: flow.screen))
                XCTAssertEqual(flow.screen, .setup(origin: step))
            }
        }
    }
}

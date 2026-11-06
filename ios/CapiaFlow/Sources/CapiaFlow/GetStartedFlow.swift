public enum IntroStep: CaseIterable, Sendable {
    case register, monthlyOverview, goals

    public var position: Int {
        switch self {
        case .register: 1
        case .monthlyOverview: 2
        case .goals: 3
        }
    }
}

public enum GetStartedScreen: Equatable, Sendable {
    case welcome
    case introduction(IntroStep)
    case configurationEntry(origin: IntroStep)
}

public struct GetStartedAction: Sendable {
    public enum Intent: CaseIterable, Sendable {
        case start, continueIntroduction, back, skip, configure, returnToIntroduction
    }

    public let intent: Intent
    public let source: GetStartedScreen

    public init(_ intent: Intent, from source: GetStartedScreen) {
        self.intent = intent
        self.source = source
    }
}

public struct GetStartedFlow: Sendable {
    public private(set) var screen: GetStartedScreen = .welcome

    public init() {}

    public mutating func send(_ action: GetStartedAction) {
        guard action.source == screen else { return }
        switch (screen, action.intent) {
        case (.welcome, .start):
            screen = .introduction(.register)
        case (.introduction(.register), .continueIntroduction):
            screen = .introduction(.monthlyOverview)
        case (.introduction(.monthlyOverview), .continueIntroduction):
            screen = .introduction(.goals)
        case (.introduction(.register), .back):
            screen = .welcome
        case (.introduction(.monthlyOverview), .back):
            screen = .introduction(.register)
        case (.introduction(.goals), .back):
            screen = .introduction(.monthlyOverview)
        case (.introduction(let step), .skip):
            screen = .configurationEntry(origin: step)
        case (.introduction(.goals), .configure):
            screen = .configurationEntry(origin: .goals)
        case (.configurationEntry(let origin), .returnToIntroduction):
            screen = .introduction(origin)
        default:
            break
        }
    }
}

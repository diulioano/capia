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
    /// Configuração inicial aberta a partir de uma etapa da apresentação.
    case setup(origin: IntroStep)
}

public struct GetStartedAction: Sendable {
    public enum Intent: CaseIterable, Sendable {
        case start, continueIntroduction, back, skip, configure, returnFromSetup
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
            screen = .setup(origin: step)
        case (.introduction(.goals), .configure):
            screen = .setup(origin: .goals)
        case (.setup(let origin), .returnFromSetup):
            screen = .introduction(origin)
        default:
            break
        }
    }
}

import Foundation

/// Destino único da raiz do app: Get Started, configuração ou Início.
public struct AppFlow: Sendable {
    public enum Screen: Equatable, Sendable {
        case getStarted(GetStartedScreen)
        case setup(SetupStep)
        case home(HomeTab)
    }

    public private(set) var getStarted: GetStartedFlow
    /// Presente enquanto a configuração está aberta ou após concluída na sessão.
    public private(set) var setup: SetupFlow?
    /// Estado do Início na sessão: aba atual, aba de categorias e valores ocultos.
    public private(set) var home = HomeFlow()
    /// Espaço exibido no Início: o guardado ou o da última conclusão da sessão.
    public private(set) var space: ConfiguredSpace?
    private var showingHome: Bool

    /// Com espaço guardado, abre no Início; caso contrário, nas boas-vindas.
    public init(saved: ConfiguredSpace?) {
        // Um espaço guardado nunca volta à apresentação; o Get Started fica na configuração.
        getStarted = saved == nil ? GetStartedFlow() : .atSetup()
        setup = saved.map(SetupFlow.init(restoring:))
        space = saved
        showingHome = saved != nil
    }

    public var screen: Screen {
        if showingHome { return .home(home.tab) }
        if case .setup = getStarted.screen, let setup { return .setup(setup.step) }
        return .getStarted(getStarted.screen)
    }

    /// Edita o rascunho da configuração aberta. Não muda a etapa.
    public mutating func editDraft(_ edit: (inout SetupDraft) -> Void) {
        guard case .setup = screen, var flow = setup else { return }
        edit(&flow.draft)
        setup = flow
    }

    public mutating func send(_ action: GetStartedAction) {
        guard case .getStarted = screen else { return }
        getStarted.send(action)
        if case .setup(let origin) = getStarted.screen {
            setup = SetupFlow(origin: origin)
        }
    }

    /// Aplica a ação na configuração. Devolve o espaço a guardar quando a ação
    /// leva à conclusão; configurações interrompidas nunca produzem espaço.
    @discardableResult
    public mutating func send(_ action: SetupAction, now: Date = Date()) -> ConfiguredSpace? {
        guard case .setup = screen, var flow = setup else { return nil }
        let before = flow.step
        let exit = flow.send(action)
        setup = flow
        switch exit {
        case .introduction?:
            getStarted.send(.init(.returnFromSetup, from: getStarted.screen))
            setup = nil
        case .month?:
            if let current = flow.space(completedAt: space?.completedAt ?? now) { space = current }
            home.showMonth()
            showingHome = true
        case nil:
            if before != .done, flow.step == .done { return flow.space(completedAt: now) }
        }
        return nil
    }

    /// Aplica uma ação do Início. Fora do Início, não faz nada.
    public mutating func send(_ action: HomeAction) {
        guard showingHome else { return }
        home.send(action)
    }

    /// "Recebi" no salário previsto do mês. Devolve o espaço a guardar; sem salário, fora
    /// do Início ou com o mês já confirmado, não muda nada e devolve `nil`.
    @discardableResult
    public mutating func confirmSalary(in calendar: MonthCalendar, now: Date = Date()) -> ConfiguredSpace? {
        guard showingHome, var current = space, let amount = current.monthlySalary,
              current.salaryReceipt(year: calendar.year, month: calendar.month) == nil else { return nil }
        let receipt = SalaryReceipt(year: calendar.year, month: calendar.month, amount: amount, confirmedAt: now)
        current.salaryReceipts.append(receipt)
        setup?.recordSalaryReceipt(receipt)
        space = current
        return current
    }

    /// "Adicionar outra conta" na aba Contas: abre o cadastro de conta da configuração.
    /// Ao concluir, a conclusão grava o espaço e "Ver meu mês" volta ao Início.
    public mutating func addAnotherAccountFromHome() {
        guard showingHome, home.tab == .accounts, var flow = setup, flow.step == .done else { return }
        flow.send(.init(.addAnotherAccount, from: .done))
        setup = flow
        showingHome = false
    }

    /// Espaço atual, para tentar gravar de novo após uma falha.
    public func currentSpace(now: Date = Date()) -> ConfiguredSpace? {
        setup?.space(completedAt: now)
    }
}

extension GetStartedFlow {
    /// Estado usado quando a conclusão é exibida a partir de um espaço guardado.
    static func atSetup() -> GetStartedFlow {
        var flow = GetStartedFlow()
        flow.send(.init(.start, from: .welcome))
        flow.send(.init(.skip, from: .introduction(.register)))
        return flow
    }
}

import Foundation

/// Destino único da raiz do app: Get Started, configuração ou mês provisório.
public struct AppFlow: Sendable {
    public enum Screen: Equatable, Sendable {
        case getStarted(GetStartedScreen)
        case setup(SetupStep)
        case month
    }

    public private(set) var getStarted: GetStartedFlow
    /// Presente enquanto a configuração está aberta ou após concluída na sessão.
    public private(set) var setup: SetupFlow?
    private var showingMonth: Bool

    /// Com espaço guardado, abre no mês; caso contrário, nas boas-vindas.
    public init(saved: ConfiguredSpace?) {
        // Um espaço guardado nunca volta à apresentação; o Get Started fica na configuração.
        getStarted = saved == nil ? GetStartedFlow() : .atSetup()
        setup = saved.map(SetupFlow.init(restoring:))
        showingMonth = saved != nil
    }

    public var screen: Screen {
        if showingMonth { return .month }
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
            showingMonth = true
        case nil:
            if before != .done, flow.step == .done { return flow.space(completedAt: now) }
        }
        return nil
    }

    /// "Voltar ao resumo": do mês para a conclusão do espaço atual.
    public mutating func returnFromMonth() {
        guard showingMonth, setup?.step == .done else { return }
        showingMonth = false
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

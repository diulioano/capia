/// Abas da barra inferior do Início.
public enum HomeTab: CaseIterable, Equatable, Sendable {
    case month, accounts, goals
}

/// Abas de "Para onde foi".
public enum CategoryTab: CaseIterable, Equatable, Sendable {
    case expenses, income
}

public enum HomeAction: Equatable, Sendable {
    case select(HomeTab)
    /// Indicador Fatura: leva a Contas.
    case openBill
    case selectCategory(CategoryTab)
    case toggleValuesHidden
    /// Abre e fecha o novo registro, cujo estado fica em `AppFlow.record`.
    case openNewRecord
    case closeNewRecord
}

/// Estado do Início durante a sessão. Nada daqui é guardado no aparelho.
public struct HomeFlow: Equatable, Sendable {
    public private(set) var tab: HomeTab = .month
    public private(set) var categoryTab: CategoryTab = .expenses
    public private(set) var valuesHidden = false

    public init() {}

    public mutating func send(_ action: HomeAction) {
        switch action {
        case .select(let tab):
            self.tab = tab
        case .openBill:
            tab = .accounts
        case .selectCategory(let category):
            categoryTab = category
        case .toggleValuesHidden:
            valuesHidden.toggle()
        case .openNewRecord, .closeNewRecord:
            break
        }
    }

    /// Volta ao mês, preservando a escolha de ocultar valores na sessão.
    mutating func showMonth() {
        tab = .month
        categoryTab = .expenses
    }
}

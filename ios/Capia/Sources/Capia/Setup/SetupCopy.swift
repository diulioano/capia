import CapiaFlow
import SwiftUI
import UIKit

/// Textos do quadro "Configuração inicial", na grafia exata da referência.
enum SetupCopy {
    static func tip(for step: SetupStep) -> String {
        switch step {
        case .name: "Oi! Vamos arrumar seu cantinho."
        case .goals: "Pode escolher mais de um."
        case .account: "Comece pela conta que você mais usa."
        case .balance: "Pode ser um valor aproximado."
        case .cardQuestion: "Cartões ficam separados da conta, mesmo no mesmo banco."
        case .cardDates: "Assim eu sei em qual fatura cada compra cai."
        case .done: ""
        }
    }

    static func title(for step: SetupStep, draft: SetupDraft) -> String {
        switch step {
        case .name: "Como podemos te chamar?"
        case .goals: "\(greeting(draft)), o que te trouxe aqui?"
        case .account: "Vamos cadastrar sua primeira conta"
        case .balance: "Quanto tem hoje em \(draft.accountDisplayName)?"
        case .cardQuestion: "Você usa cartão de crédito de \(draft.accountDisplayName)?"
        case .cardDates: "Datas do cartão \(draft.accountDisplayName)"
        case .done: "Tudo pronto, \(greeting(draft))!"
        }
    }

    /// Primeiro nome; o design usa "Tudo certo" quando não há nome.
    static func greeting(_ draft: SetupDraft) -> String {
        draft.greeting.isEmpty ? "Tudo certo" : draft.greeting
    }

    static func label(_ goal: SetupGoal) -> String {
        switch goal {
        case .understandSpending: "Entender para onde vai meu dinheiro"
        case .saveForGoal: "Juntar dinheiro para um objetivo"
        case .organizeCardBills: "Organizar as faturas do cartão"
        case .leaveSpreadsheet: "Deixar a planilha de lado"
        }
    }

    @MainActor
    static func image(for mood: SetupMood) -> UIImage {
        switch mood {
        case .calm: CapiaImages.calmCapybara
        case .thinking: CapiaImages.thinkingCapybara
        case .happy: CapiaImages.happyCapybara
        case .celebrating: CapiaImages.celebratingCapybara
        }
    }
}

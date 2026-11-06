import CapiaFlow
import SwiftUI

/// Falar e Foto nesta entrega: capivara calma, aviso de que vêm na próxima etapa e
/// "Digitar", que volta ao teclado com o tipo e o valor. Não pede permissão nem simula leitura.
@MainActor
struct RecordModePlaceholderView: View {
    let mode: RecordMode
    let send: (RecordAction) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(uiImage: CapiaImages.calmCapybara)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .accessibilityHidden(true)
                Text(RecordCopy.modePlaceholder(mode))
                    .font(CapiaFonts.title(20))
                    .foregroundStyle(CapiaTheme.tipText)
                    .multilineTextAlignment(.center)
                    // Altura de linha 1,4 do quadro.
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                Button(RecordCopy.modeLabel(.type)) { send(.selectMode(.type)) }
                    .buttonStyle(CapiaContinueButtonStyle())
                    .accessibilityHint("Volta a Digitar, com o que já foi preenchido")
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.horizontal, 22)
            .padding(.bottom, 40)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

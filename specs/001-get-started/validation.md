# Validação do Get Started — Capia

## Base compartilhada — 2026-11-06

- Branch: `feat/001-get-started`; revisão anterior: `bf4c8cd33c31681a3e0acf5483480b5c50f32999`. Código validado no commit que inclui este registro.
- Ambiente observado: Ubuntu no WSL, Swift 6.4.2, xtool 1.24.0, SDK Darwin slim instalado em `/home/diuli/.swiftpm/swift-sdks/darwin.artifactbundle`, epoch 4, darwinTools 1.1.0, oam 1.4.1.
- O usuário confirmou anteriormente que compilou e executou o app padrão no iPhone. Esse relato permanece válido; não constitui instalação do Capia.
- `xtool devices --no-wait`: saída vazia, nenhum aparelho disponível nesta sessão.

Comandos executados pelo Bash (`wsl -d Ubuntu -- bash -lc`), a partir de `/mnt/c/Users/Diuli/.t3/projects/i-dont-the-name-yet`:

```bash
cd ios
xtool new Capia --skip-setup
cd ..
swift test --package-path ios/CapiaFlow
cd ios/Capia
xtool dev build
```

Resultados:

- T001–T003: pacotes library Swift 6 criados; app iOS 17, dependência local CapiaFlow, metadados Capia e bundle `com.diuli.capia`. Sem ícone antecipado nem credenciais versionadas.
- T004–T006: seis testes XCTest passaram, zero falhas. Cobrem percurso completo, todos os retornos, Pular e origem, nova instância, eventos repetidos e ações incompatíveis.
- T007: raiz SwiftUI possui `@State`, isolada no ator principal; todos os casos de tela e ações estão ligados ao modelo puro. Origem capturada na renderização, sem roteador ou persistência.
- T008: `xtool dev build` passou. Artefato real: `/mnt/c/Users/Diuli/.t3/projects/i-dont-the-name-yet/ios/Capia/xtool/Capia.app` (Windows: `ios/Capia/xtool/Capia.app`). Inspeção do Info.plist gerado confirma identificação Capia e bundle `com.diuli.capia`.
- Referência consultada: primeiro quadro `d017ec14-a843-4b61-ab79-5bedc20a48eb`, incluindo composição welcome e navegação das introduções. O HTML foi apenas lido e descompactado fora do repositório para consulta.
- As telas desta base são explicitamente provisórias. Compilação e testes puros não comprovam renderização ou interação no iPhone.
- **Pendente**: assinatura, instalação e abertura do Capia no iPhone; comparação visual, VoiceOver, texto ampliado e redução de movimento. Capia ainda não foi instalado nem validado no aparelho nesta sessão.

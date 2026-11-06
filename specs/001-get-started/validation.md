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

## US1 — implementação parcial em 2026-11-06

- Branch: `feat/001-get-started-us1-welcome`, avançada por `git merge --ff-only feat/001-get-started` a partir de `5cf72fc`. Código verificado no commit parcial que contém este registro.
- T009: preparação do mascote original (WEBP → PNG sem alteração de pixels) e cópia exata do fundo. HTML original preservado por SHA-256. Manifesto e `SOURCES.md` registram hashes e origens.
- T010: Figtree completa e Zen Maru Gothic Bold do repositório oficial Google Fonts, revisão `38411257417e616c5d4daa1b9e91a3dbcebe1c2e`, com OFL. Instâncias estáticas Figtree 400, 600 e 700 criadas sem subset por fonttools; nomes PostScript conferidos. Registro Core Text antes da primeira view e fontes SwiftUI com escala semântica.
- T011–T015: boas-vindas com textos, cores e medidas do quadro; carinho local de 1,9 segundo renovável, cancelamento ao sair, cena com vapor, reflexo, brilho e ondulações. Canvas e TimelineView param ao sair e com redução de movimento; decorações não interceptam toques. Mascote tem nome acessível, feedback anunciado sem mudar foco e título recebe foco. A origem de Começar permanece capturada na renderização.
- Adaptações a conferir no aparelho: topo e rodapé respeitam área segura; texto acessível ou altura útil menor que 620 pontos reorganiza a welcome em rolagem com texto, recorte inferior da cena (360 pontos) e ação. Balão centralizado com largura limitada para texto ampliado. O botão tem altura mínima 58 e cresce com o texto. A adaptação prioriza leitura e mantém o alvo de carinho sobre o mascote.
- Consulta estática ao quadro: recuos 28/24, título 34, corpo 16, mascote 72 × 61 na origem (170, 607), imagem de fundo 390 × 844 e reflexo correspondente. A comparação visual do resultado nativo ainda não foi realizada.

Verificações executadas:

```powershell
python -m pip install -r scripts/requirements-design-assets.txt
python scripts/prepare-design-assets.py
python scripts/prepare-design-assets.py --check
```

- Preparação repetida comparando hashes de todos os arquivos: resultado idêntico. `--check` passou sem modificar recursos. Conferidos pixels da capivara, igualdade do fundo, dimensões, cabeçalhos TTF, nomes PostScript, licenças e hashes.
- `xtool dev build` no Bash em `ios/Capia`: passou com as boas-vindas e os recursos. Artefato: `ios/Capia/xtool/Capia.app`.
- Inspeção do `.app`: nome e bundle Capia confirmados; imagens, fontes e arquivos OFL encontrados uma única vez e iguais byte a byte aos recursos de origem.
- **T016 pendente**: nenhum iPhone listado em nova execução de `xtool devices --no-wait`. Sem instalação, execução, capturas nativas, VoiceOver, maior texto acessível, redução de movimento ou observação de SC-001. O comportamento de renovação/saída foi implementado, mas não observado no aparelho.
- US1 salva como parcial. US2, US3 e validação integrada permanecem abertas; `tasks.md` exige o checkpoint T016 antes da história seguinte. SC-002 a SC-006 também pendentes.
- Não há `.specify/extensions.yml`: nenhum hook de implementação registrado.

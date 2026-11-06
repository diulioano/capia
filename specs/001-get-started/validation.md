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
- `.gitattributes` preserva bytes do HTML e das fontes/licenças contra conversão de fim de linha no checkout Windows. Espaços finais dos avisos OFL originais são preservados.
- `xtool dev build` no Bash em `ios/Capia`: passou com as boas-vindas e os recursos. Artefato: `ios/Capia/xtool/Capia.app`.
- Inspeção do `.app`: nome e bundle Capia confirmados; imagens, fontes e arquivos OFL encontrados uma única vez e iguais byte a byte aos recursos de origem.
- **T016 pendente**: nenhum iPhone listado em nova execução de `xtool devices --no-wait`. Sem instalação, execução, capturas nativas, VoiceOver, maior texto acessível, redução de movimento ou observação de SC-001. O comportamento de renovação/saída foi implementado, mas não observado no aparelho.
- US1 salva como parcial. US2, US3 e validação integrada permanecem abertas; `tasks.md` exige o checkpoint T016 antes da história seguinte. SC-002 a SC-006 também pendentes.
- Não há `.specify/extensions.yml`: nenhum hook de implementação registrado.

## Instalação da US1 no iPhone — 2026-11-06

- Revisão instalada: `364091f`, branch `feat/001-get-started-us1-welcome`.
- Aparelho identificado por `ideviceinfo`: `iPhone15,2`, iOS `26.7.2`.
- A conexão direta via usbipd listou o aparelho e validou o pareamento após desbloqueio,
  mas duas instalações pararam em `[Connecting] 100%`. O serviço usbmuxd registrou
  `asyncReadComplete, message was too large (65536 bytes, max = 65535)`.
- Reiniciar usbmuxd e reconectar o USB restaurou a enumeração, mas não resolveu a transferência.
  O erro voltou no mesmo estágio. Não houve alteração no código Swift para tratar essa falha.
- Contorno testado: liberar a associação `Shared (forced)` do iPhone por
  `usbipd unbind --busid 2-5` (executado com privilégio de administrador), devolvendo-o ao
  Apple Devices no Windows. O processo AppleMobileDeviceProcess já escutava em
  `127.0.0.1:27015`; WSL usa rede mirrored. Nenhum firewall ou portproxy foi alterado.
- A causa e o contorno correspondem ao [relato upstream do xtool](https://github.com/xtool-org/xtool/issues/19)
  e à [falha de transferência reportada ao usbmuxd](https://github.com/libimobiledevice/usbmuxd/issues/247).

Comando executado em `ios/Capia`, pelo Bash:

```bash
USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb
```

- **Passou**: compilação, assinatura, instalação e verificação pelo aparelho, todas concluídas.
  Processo terminou com código zero e `[Installing] 100%`, `[Verifying] 100%`.
- **Passou**: consulta dos apps instalados por `ideviceinstaller list`, filtrada para Capia,
  confirma nome Capia. A assinatura xtool acrescenta `XTL-<equipe>.` ao identificador
  `com.diuli.capia`; o identificador do pacote sem assinatura permanece conforme o plano.
- `ideviceinstaller` 1.2.0 instalado no Ubuntu para conferir a instalação real; não é dependência do app.
- **Falhou**: `xtool launch` com o identificador instalado chega a `Launching Capia...`,
  mas retorna `DebugserverClient.Error.unknown`. Abertura manual pelo ícone solicitada ao usuário.
- **T016 permanece pendente**: instalação comprovada, mas abertura, interação, fidelidade visual,
  VoiceOver, maior texto acessível, redução de movimento e SC-001 ainda não observados.
  Este registro atualiza o estado de conexão e instalação relatado nas seções anteriores.

## Capturas recebidas e correção das imagens — 2026-11-06

- As cinco capturas enviadas pelo usuário foram preservadas sem edição em
  [evidence/us1-build1/](evidence/us1-build1/). Elas confirmam abertura real da welcome
  e presença das três introduções e configuração provisórias.
- **Falhou**: [welcome.png](evidence/us1-build1/welcome.png) mostra textos, botão e vapor,
  mas o fundo onsen, a capivara e seu reflexo estão ausentes. A US1 não atende ao design.
  A interpretação anterior de problema na tela inicial ou de versão antiga foi inadequada;
  a captura mostra a welcome implementada com falha no conteúdo de imagem.
- As outras quatro capturas correspondem às telas provisórias esperadas antes da US2.
  Não comprovam aceite da apresentação final. T016 segue pendente, e T012/T014 foram
  reabertas até confirmar a correção visual.
- Inspeção do artefato: PNGs RGBA válidos, dimensões corretas e bytes iguais às origens,
  presentes no `Capia_Capia.bundle`. O acessor `Bundle.module` gerado encontra esse bundle;
  o executável contém WelcomeView e suas referências. Isso não comprova que a busca
  de imagens por nome do SwiftUI consiga resolvê-las em execução.
- Correção candidata: `CapiaImages` resolve a URL PNG por `Bundle.module` e cria uma
  `UIImage(contentsOfFile:)`, usada em `Image(uiImage:)`. As imagens são carregadas uma
  única vez; ausência ou falha de decodificação deixa de produzir uma cena vazia silenciosa.
- `CFBundleVersion` incrementado de 1 para 2 para distinguir a próxima instalação.
- **Passou**: `xtool dev build`, `python scripts/prepare-design-assets.py --check` e inspeção
  de metadados/PNGs do `.app` da build 2. Sem alteração das imagens ou do HTML.
- **Pendente**: reinstalar build 2 e repetir a conferência visual e o carinho no iPhone.
  A conexão `USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015` não listava aparelhos ao final dessas
  verificações; solicitado manter iPhone desbloqueado e visível em Dispositivos Apple.
  Não há host UIKit neste ambiente Linux para substituir essa verificação por um teste nativo.

## Reinstalação da build 2 — 2026-11-06

- Revisão instalada: `9a1a2a4`, branch `feat/001-get-started-us1-welcome`.
- Conexão Apple do Windows voltou a listar o mesmo iPhone pelo socket local 27015.
- Executado em `ios/Capia`: `USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb`.
- **Passou**: compilação, instalação e verificação (`[Installing] 100%`, `[Verifying] 100%`, código zero).
- **Passou**: consulta do app no aparelho por `ideviceinstaller list`, restrita ao identificador
  instalado do Capia e aos campos CFBundleIdentifier, CFBundleVersion e CFBundleDisplayName,
  retornou versão de build `2` e nome `Capia`.
- **Pendente**: abertura manual da build 2 e confirmação visual do fundo e da capivara.
  Solicitada ao usuário. T012, T014 e T016 continuam abertas; compilação e instalação
  não confirmam que o problema visual foi resolvido.

## Confirmação do carregamento das imagens — 2026-11-06

- Após a reinstalação da build 2, o usuário confirmou explicitamente que cenário onsen
  e capivara aparecem nas boas-vindas: "Sim, aparecem os dois".
- **Passou por relato do usuário no aparelho**: exibição das duas imagens, antes ausentes.
  A troca da busca por nome por URLs PNG explícitas resolveu o sintoma observado.
- Nova tentativa de captura por `idevicescreenshot` encontrou o aparelho, mas falhou
  ao iniciar o serviço: `Could not start screenshotr service: Invalid service`.
  Não foi obtida captura da build 2 por esse caminho; não há comparação visual completa nova.
- Solicitados os testes de carinho (mensagem, renovação e saída com retorno sem balão),
  uso sem rede, redução de movimento, maior texto acessível e VoiceOver.
  Resultados ainda pendentes. T012/T014 permanecem reabertas até a conferência completa;
  T016 segue pendente e a US2 não foi iniciada.

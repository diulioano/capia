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

## Interação da capivara confirmada — 2026-11-06

- Na build 2, o usuário respondeu "Tudo funcionou" ao percurso de tocar na capivara,
  conferir a mensagem, tocar novamente após aproximadamente um segundo para renovar
  a duração, acionar Começar durante o feedback e voltar sem balão antigo.
- **Passou por relato do usuário no aparelho**: mensagem, renovação, navegação disponível
  durante o feedback e limpeza ao sair/retornar. Não foi medido o tempo exato do balão.
- O usuário informou "Ainda não testei" para os cenários sem rede, Reduzir Movimento,
  maior tamanho de texto acessível e VoiceOver. Esses quatro cenários permanecem pendentes,
  assim como a comparação visual completa e SC-001. T016 não foi concluída.

## Reduzir Movimento confirmado — 2026-11-06

- O usuário respondeu "deu bom" ao teste de ativar Reduzir Movimento nos Ajustes,
  conferir a cena estática e testar carinho, Começar e Voltar na build 2.
- **Passou por relato do usuário no aparelho**: preferência de redução de movimento
  respeitada, com as interações disponíveis.
- Próximo cenário: uso sem rede. Maior tamanho de texto acessível, VoiceOver,
  comparação visual completa e SC-001 continuam pendentes; T016 permanece aberta.

## Uso sem rede confirmado — 2026-11-06

- O usuário respondeu "funcionou" ao teste de ativar modo avião, desligar o Wi-Fi,
  fechar e reabrir o Capia e conferir fundo, capivara, carinho, Começar e Voltar.
- **Passou por relato do usuário no aparelho**: imagens e interações disponíveis sem rede,
  incluindo reabertura. A nova execução apresentou as boas-vindas.
- Maior tamanho de texto acessível, VoiceOver, comparação visual completa e SC-001
  continuam pendentes; T016 permanece aberta.

## Texto ampliado — falha visual relatada em 2026-11-06

- No maior tamanho de texto de acessibilidade, o usuário relatou: "quebrou o layout
  mas continua funcional, e a imagem ficou estranha".
- **Falhou visualmente por relato do usuário no aparelho**: a funcionalidade permanece
  acessível, mas a composição e a apresentação da imagem não foram aceitas.
- Revisão inicial do código: esse modo usa uma coluna rolável com cena de altura fixa
  de 360 pontos e um deslocamento vertical próprio. A captura do resultado foi solicitada
  para identificar o defeito concreto antes de alterar enquadramento ou tipografia.
- O cenário de maior texto não está aprovado. T012, T014 e T016 continuam abertas;
  VoiceOver, comparação visual completa e SC-001 também permanecem pendentes.

## Vídeo de texto ampliado e build 3 — 2026-11-06

- Evidência recebida: `WhatsApp Video 2026-11-06 at 11.06.07.mp4`, 25,71 segundos,
  384 × 848 pixels, SHA-256 `bdf4eb8b1e3237c36d95104e68c15a464caf64cca56fbf632de68613259593a7`.
  Original mantido no anexo da conversa, sem alteração. Quadros de diagnóstico preservados
  em [evidence/us1-build2/](evidence/us1-build2/), extraídos a 300 pixels de largura.
- Quadros observados no vídeo: texto passa sob a barra de status ao rolar; a cena
  surge como faixa com corte abrupto após o texto. As ações continuam disponíveis.
  O crescimento e a quebra de linhas do texto são esperados com Dynamic Type; não foi
  reduzido nem limitado o tamanho escolhido pelo usuário para tentar imitar a composição base.
- Ajuste da build 3: coluna rolável recortada à área útil e Começar em `safeAreaInset`
  inferior. O rodapé reserva espaço e permanece alcançável sem percorrer todo o texto.
- Cena agora é composta em um único espaço 390 × 844 e recebe uma transformação comum
  para fundo, mascote, reflexo, efeitos e alvo de toque. Removida a heurística de recorte
  por altura física, aplicada anteriormente a cada camada.
- No modo de leitura, o recorte é a região y=444…844 da referência, escalada pela largura,
  com altura proporcional de 400/390 e transição superior para o creme. O feedback ocupa
  uma região reservada acima da cena; sua aparição não muda a posição do mascote.
- No modo de tela inteira, as coordenadas da referência e o enquadramento por cobertura
  são mantidos. O contrato registra a reorganização para acessibilidade.
- **Passou**: `xtool dev build` e `python scripts/prepare-design-assets.py --check`.
  `CFBundleVersion` elevado para 3; recursos originais e HTML permanecem intactos.
- **Pendente**: instalar a build 3 e conferir texto máximo, rolagem, cena, feedback e
  regressão em tamanho padrão no iPhone. O socket Apple não listava aparelho na tentativa
  de conexão desta etapa. Solicitada reconexão ao usuário. T012/T014/T016 continuam abertas.

## Instalação da build 3 — 2026-11-06

- Revisão instalada: `e65e5e5`, branch `feat/001-get-started-us1-welcome`.
- Após o usuário reconectar, o iPhone voltou a ser listado pelo socket Apple do Windows.
- Executado em `ios/Capia`: `USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb`.
- **Passou**: compilação, instalação e verificação do pacote no aparelho,
  com `[Installing] 100%`, `[Verifying] 100%` e término com código zero.
- **Passou**: `ideviceinstaller list`, restrito ao Capia, confirma CFBundleVersion `3`
  e CFBundleDisplayName `Capia` no aparelho.
- **Pendente**: conferência da build 3 com texto máximo (rolagem, cena, botão fixo e carinho),
  regressão visual em tamanho padrão e demais verificações ainda abertas da US1.
  O resultado foi solicitado ao usuário; T012/T014/T016 continuam abertas.

## Texto ampliado aprovado na build 3 — 2026-11-06

- O usuário respondeu "Layout e carinho funcionaram bem" à conferência da build 3
  com o texto no máximo, incluindo rolagem, recorte da cena, Começar fixo no rodapé
  e toque na capivara.
- **Passou por relato do usuário no aparelho**: reorganização para o maior texto
  acessível e interação de carinho após a mudança. O defeito visual relatado na build 2
  não foi observado pelo usuário nesse percurso da build 3.
- Permanecem pendentes a conferência da composição em tamanho padrão após o ajuste,
  VoiceOver e SC-001. T016 continua aberta; US2 ainda não iniciada.

## Tamanho padrão e VoiceOver aprovados — 2026-11-06

- O usuário respondeu "sim, está de boa" à conferência da cena em tamanho padrão e
  ao teste com VoiceOver: foco no título ao abrir/trocar de tela, nome acessível da
  capivara, anúncio do feedback e funcionamento de Começar e Voltar.
- **Passou por relato do usuário no aparelho**: aparência em tamanho padrão e os
  comportamentos de VoiceOver solicitados, na build 3.
- O conjunto já tem relatos positivos para imagens, carinho e renovação, saída e retorno,
  redução de movimento, uso sem rede, maior texto acessível e VoiceOver. O teste de texto
  ampliado foi repetido e aprovado após a correção da build 3.
- **Pendente para fechar T016**: SC-001 (entender a proposta e iniciar em até 15 segundos
  sem orientação). O critério foi perguntado explicitamente ao usuário; não foi inferido
  a partir da aprovação das outras verificações. US2 ainda não iniciada.

## Aceite da US1 — 2026-11-06

- SC-001 aprovado por relato do usuário: "Sim, em até 15 segundos", em resposta ao
  critério de entender a proposta e iniciar a apresentação sem orientação.
- T012, T014 e T016 concluídas com os resultados registrados nas seções anteriores.
  Aceite no iPhone15,2 / iOS 26.7.2, build 3 (`e65e5e5`), apoiado nas verificações
  do usuário para aparência padrão, maior texto, VoiceOver, movimento reduzido,
  uso sem rede e carinho. O tempo de SC-001 foi informado pelo usuário, sem medição instrumental.
- US1 aceita; as introduções ainda são provisórias. US2 e US3 não estão concluídas.

## US2 — apresentação implementada, build 4 — 2026-11-06

- Branch `feat/001-get-started-us2-introduction`, avançada por fast-forward até o aceite
  da US1 em `0158a87` antes da implementação da US2. Código verificado no commit parcial
  que inclui este registro.
- Consultados template do quadro Get Started e componente Capivara do HTML original,
  preservado sem edição. Os textos e posições foram lidos diretamente do quadro.
- T017: o componente Capivara aponta para blobs externos das seis expressões, ausentes
  dos sete quadros exportados. Aplicada a alternativa das tarefas: folha existente
  `assets/capybara-expressions-sheet-3x2.png`, cujo prompt documenta as mesmas expressões.
  Células: pensando (2,0), feliz (1,0), comemora (1,1). Recorte e remoção do branco conectado
  às bordas, sem redesenho. A correspondência é semântica e visual com a folha existente;
  não há comparação pixel a pixel com os blobs ausentes. Origens e hashes registrados
  em `Resources/SOURCES.md` e `sources.json`.
- T018–T020: painéis no espaço 350 × 400 da referência, opções ilustrativas, resumo
  Novembro com 35/20/13/11% sem normalização e meta Viagem ao Japão com 68% e
  R$ 12.240 de R$ 18.000. Nenhuma captura, permissão ou cálculo financeiro implementado.
- T021–T023: três títulos e descrições exatos, Voltar, Pular, progresso derivado e ação
  final correta; configuração com tema, mensagem e retorno previstos. Removidos os textos
  do esqueleto. Estado e transições continuam em CapiaFlow com origem capturada na renderização.
  Cada etapa recria sua view para reiniciar rolagem, animação e foco, sem recriar o fluxo.
- T024: controles com alvo mínimo 44, cabeçalho com foco assistivo após montagem,
  progresso como um elemento "Etapa N de 3" e exemplos identificados. Conteúdo rolável
  recortado à área útil; navegação e rodapé acessíveis. No maior texto, o rodapé empilha
  progresso/botão e os painéis ganham uma descrição textual ampliada com todos os valores.
  A arte mantém proporção e tipografia interna; a descrição substitui sua leitura assistiva
  nesse modo para evitar duplicação. Decisão documentada no contrato.
- Barras, nível da meta e entradas têm animações discretas; etiquetas/mascotes flutuam
  levemente. Reduzir Movimento mostra valores finais sem movimentos contínuos, e as
  timelines pausam fora da tela. Nenhuma ação aguarda animações.

Verificações:

- `swift test --package-path ios/CapiaFlow`: seis testes passaram, zero falhas, cobrindo
  percurso, retornos, Pular de cada origem, ações incompatíveis e eventos antigos repetidos.
- `python scripts/prepare-design-assets.py --check`: passou. Preparação repetida preservou
  hashes; conferência sem escrita. Poses comparadas à extração reproduzível com transparência,
  fontes/licenças e recursos US1 intactos.
- `xtool dev build`: passou; artefato `ios/Capia/xtool/Capia.app`, CFBundleVersion 4.
- **T025 pendente**: instalação e percurso da US2 no iPhone, comparação dos painéis,
  retornos, toques rápidos, acessibilidade e SC-002 a SC-005. Conexão Apple não listava
  aparelho; reconexão solicitada ao usuário. US3 não iniciada.

## Instalação da US2, build 4 — 2026-11-06

- Revisão instalada: `7a1a421`, branch `feat/001-get-started-us2-introduction`.
- Após o usuário confirmar o aparelho visível, `xtool devices --no-wait` pelo socket
  Apple do Windows voltou a listar o mesmo iPhone.
- Executado em `ios/Capia`: `USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb`.
- **Passou**: compilação, assinatura, instalação e verificação. Processo terminou com
  código zero após `[Installing] 100%` e `[Verifying] 100%`.
- **Passou**: consulta `ideviceinstaller list` restrita ao Capia confirma CFBundleVersion
  `4` e CFBundleDisplayName `Capia` no aparelho.
- **Pendente**: abrir pelo ícone e validar o percurso completo, painéis e retorno da
  configuração em até um minuto; solicitado ao usuário. Os demais cenários da US2
  também permanecem abertos. Instalação não conclui T025; US3 não iniciada.

## Percurso principal da US2 aprovado — 2026-11-06

- O usuário respondeu "Sim, tudo funcionou" ao percurso Começar → Continuar →
  Continuar → Configurar meu espaço, incluindo aparência correta dos três painéis,
  conclusão em até um minuto e Voltar à apresentação retornando à etapa de metas.
- **Passou por relato do usuário no aparelho, build 4**: percurso principal e retorno
  da configuração aberta pela ação final. SC-002 aprovado pelo tempo informado,
  sem medição instrumental. Aparência dos três painéis aprovada no percurso observado.
- **Pendente**: Voltar de todas as etapas, Pular de cada origem e retornar corretamente,
  uso sem rede, toques rápidos, maior texto acessível, VoiceOver e redução de movimento
  nas novas telas. T025 continua aberta; US3 ainda não iniciada.

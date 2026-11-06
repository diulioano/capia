# Tasks: Configuração inicial do espaço

**Input**: `specs/002-initial-setup/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/initial-setup-ui.md](contracts/initial-setup-ui.md)
e [quickstart.md](quickstart.md).

**Tests**: A constituição exige testes automatizados para transições financeiras. Testes
XCTest em `ios/CapiaFlow` cobrem fluxo, validações, centavos, formato e gravação. Interface,
teclado, acessibilidade e reabertura são validados no iPhone. TDD não é obrigatório.

**Organization**: Base compartilhada primeiro; depois US1, US2, US3 e US4, na ordem da spec.
Cada US separa comportamento, interface e verificação. Marcar uma tarefa somente após
cumprir seu resultado observável.

## Format: `[ID] [P?] [Story] Description`

As tarefas usam `- [ ] TNNN [P opcional] [USN quando aplicável] descrição com caminho`.
`[P]` permite trabalho em arquivos diferentes após os pré-requisitos; não autoriza escrita
simultânea no mesmo arquivo nem cria agentes automaticamente.

## Path Conventions

- App: `ios/Capia/Sources/Capia/` (novas telas em `Setup/`).
- Comportamento puro e testes no Linux: `ios/CapiaFlow/`.
- Referência imutável: `design/App de finanças onsen — protótipo iPhone.html`, quadro `fe19fbe7-038d-4ef6-bb17-aedea28b4d3f`.
- Recursos: `assets/`; preparação reproduzível: `scripts/prepare-design-assets.py`.
- Evidências: `specs/002-initial-setup/validation.md`, com seções para base, cada US e integração.

## Branches e commits por US

Mesma regra do Get Started (AGENTS.md): uma branch por US e commits separados por US.
Branches locais; sem push, PR ou merge em `master` nesta etapa.

| Etapa | Branch | Recebe antes de começar | Commit de referência |
|-------|--------|------------------------|----------------------|
| Planejamento e base compartilhada | `feat/002-initial-setup` | `feat/001-get-started` validado | `chore(setup-base): cria fluxo, gravação e esqueleto da configuração` |
| US1: apresentar-se | `feat/002-initial-setup-us1-profile` | Base com T001–T010 | `feat(us1): adiciona nome e objetivos da configuração` |
| US2: primeira conta | `feat/002-initial-setup-us2-account` | US1 validada | `feat(us2): adiciona primeira conta e saldo inicial` |
| US3: cartão de crédito | `feat/002-initial-setup-us3-card` | US2 validada | `feat(us3): adiciona cartão separado com datas` |
| US4: conclusão | `feat/002-initial-setup-us4-done` | US3 validada | `feat(us4): adiciona conclusão, nova conta e reabertura` |
| Validação integrada | `feat/002-initial-setup` | US4 e predecessores | `chore(validation): valida configuração inicial no iPhone` |

As branches de US são criadas a partir da base depois do checkpoint da Phase 2. Antes de
trabalhar em cada uma, atualizá-la com `git merge --ff-only` da branch predecessora. Não
fazer commits de implementação de US na branch base. Se o fast-forward falhar, integrar com
merge normal preservando o histórico; não usar reset nem force-push.

É permitido mais de um commit por história com o prefixo `usN`. Cada commit inclui o
progresso em `tasks.md` e a evidência em `validation.md`. Sem aparelho, salvar como
`wip(usN): ...`, registrar pendências e manter a tarefa de validação aberta.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar o recurso novo e o registro de evidências. Sem telas.

- [X] T001 [P] Estender `scripts/prepare-design-assets.py` para preparar `ios/Capia/Sources/Capia/Resources/Images/CalmCapybara.png` da célula (0, 0) de `assets/capybara-expressions-sheet-3x2.png`, com o mesmo recorte e remoção de fundo usados nas outras poses; registrar origem e hash em `ios/Capia/Sources/Capia/Resources/SOURCES.md` e `sources.json`, e exigir o arquivo no modo `--check`; executar os dois modos.
- [X] T002 [P] Criar `specs/002-initial-setup/validation.md` com branch, revisão, versões (Swift 6.4.2, xtool 1.24.0, SDK epoch 4), evidência da ausência de `SwiftDataMacros` (research §1) e seções vazias para base, US1–US4 e integração, marcadas como pendentes.

**Checkpoint**: Recurso calmo conferido; registro de evidências criado.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Todo o comportamento testado no Linux e o esqueleto navegável, antes do visual.

- [X] T003 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/Money.swift` com `Cents` (`Int64`, 0…99.999.999.999), formatação determinística `R$ 1.234,56`, rótulo de atalho sem `,00` (`+ R$ 1.000`), soma saturada e conversão de texto digitado em centavos (somente algarismos, sem zeros à esquerda, máximo de 11), conforme research §3; testar em `ios/CapiaFlow/Tests/CapiaFlowTests/MoneyTests.swift` os casos de data-model.md.
- [X] T004 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/Space.swift` com `SetupGoal`, `AccountKind`, `Profile`, `Account`, `CreditCard` e `ConfiguredSpace` (`schemaVersion = 1`), todos `Codable`, `Equatable` e `Sendable`, com identificadores `UUID` e cartões em lista separada das contas, conforme data-model.md.
- [X] T005 Criar `ios/CapiaFlow/Sources/CapiaFlow/SetupFlow.swift` com `SetupStep`, `SetupDraft`, `SetupMode`, `SetupAction` (com etapa de origem) e `SetupFlow`: edições de campo, `canContinue`, `progressPosition`, `greeting`, `accountDisplayName`, `mood`, `space` e todas as transições da tabela de data-model.md, incluindo anexar ao chegar a `done`, remover ao voltar de `done`, `addingAccount`, saída para a apresentação e para o mês, e `init(restoring:)`; depende de T003–T004.
- [X] T006 Escrever `ios/CapiaFlow/Tests/CapiaFlowTests/SetupFlowTests.swift` cobrindo: percurso com e sem cartão, cada regra de Continuar, Voltar de todas as etapas preservando o rascunho, origem antiga ignorada, Voltar e Continuar repetidos em `done` sem duplicar, outra conta acumulando e cancelando, Carteira sem nome, humor por estado e restauração sem Voltar; asserções só sobre estado observável; depende de T005.
- [X] T007 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/SpaceStore.swift` (`init(directory:)`, `load()`, `save(_:)`), JSON com datas ISO 8601 e chaves ordenadas, gravação atômica com proteção de arquivo quando disponível, criação do diretório e `nil` para ausente, ilegível ou versão desconhecida sem apagar; testar em `ios/CapiaFlow/Tests/CapiaFlowTests/SpaceStoreTests.swift` com diretório temporário; depende de T004.
- [X] T008 Substituir `configurationEntry(origin:)` por `setup(origin:)` e `returnToIntroduction` por um retorno vindo da configuração em `ios/CapiaFlow/Sources/CapiaFlow/GetStartedFlow.swift`, atualizando `ios/CapiaFlow/Tests/CapiaFlowTests/GetStartedFlowTests.swift` para Pular nas três etapas e Configurar meu espaço; executar `swift test --package-path ios/CapiaFlow` e registrar o resultado em `specs/002-initial-setup/validation.md`.
- [X] T009 Criar `ios/Capia/Sources/Capia/AppRootView.swift` (destino único `getStarted`, `setup` ou `month`; lê `SpaceStore` em Application Support uma vez; grava ao entrar em `done` e expõe falha de gravação) e ligá-la em `ios/Capia/Sources/Capia/CapiaApp.swift`; ajustar `ios/Capia/Sources/Capia/GetStarted/GetStartedView.swift` para delegar a saída à raiz; remover `ios/Capia/Sources/Capia/GetStarted/ConfigurationEntryView.swift`; adicionar `calmCapybara` em `ios/Capia/Sources/Capia/Design/CapiaImages.swift`; depende de T001, T005, T007 e T008.
- [X] T010 Criar `ios/Capia/Sources/Capia/Setup/SetupView.swift` com etapas, conclusão e `ios/Capia/Sources/Capia/Setup/MonthPlaceholderView.swift` provisórios (texto simples e ações ligadas ao `SetupFlow`), permitindo percorrer todo o fluxo, gravar e reabrir sem tela vazia; compilar com `xtool dev build` em `ios/Capia/`, registrar comando e caminho do `.app` em `specs/002-initial-setup/validation.md`, atualizar este arquivo e fazer o commit da base; criar as quatro branches de US a partir dela.

Execução: a lógica da raiz de T009 ficou em `ios/CapiaFlow/Sources/CapiaFlow/AppFlow.swift`,
com testes em `AppFlowTests.swift`; `AppRootView` só lê e grava. Registro em `validation.md`.

**Checkpoint**: Testes passam e o app compila com o fluxo navegável provisório. Nenhuma
etapa provisória conta como tela final.

## Phase 3: User Story 1 - Apresentar-se ao Capia (Priority: P1) 🎯 MVP

**Goal**: Contêiner final da configuração e etapas de nome e objetivos fiéis ao design.
**Branch**: `feat/002-initial-setup-us1-profile`.
**Independent Test**: Da apresentação, Pular ou Configurar meu espaço; preencher nome,
escolher objetivos, chegar à etapa da conta (ainda provisória) e voltar até a apresentação.

- [X] T011 [US1] Acrescentar em `ios/Capia/Sources/Capia/Design/CapiaTheme.swift` as cores do quadro (borda `#E5D6BE`, seleção `#ECEBD6`, trilho `#E8DBC6`, inativo `#DDD3C4`/`#6B6258`, dica `#4A433B`, alerta `#9C4A22`, aviso `#45512A`, erro `#FADDCB`/`#84401E`, conclusão `#F1E8DA`) e estilos reutilizáveis de opção selecionável e de Continuar ativo/inativo, conforme contracts/initial-setup-ui.md.
- [X] T012 [US1] Implementar o contêiner final em `ios/Capia/Sources/Capia/Setup/SetupView.swift`: Voltar 44 × 44, barra de progresso N/6 animada, capivara 84 pt pelo humor derivado, balão de dica com fade, título com foco acessível e Continuar fixo em `safeAreaInset` acompanhando o teclado; redução de movimento sem animações; depende de T011.
- [X] T013 [P] [US1] Implementar `ios/Capia/Sources/Capia/Setup/NameStepView.swift`: rótulo, campo sublinhado 60 pt com placeholder "Ex.: Diuli", `.givenName`, iniciais maiúsculas, sem autocorreção, foco automático, selo de validação, "Só mais uma letrinha." anunciado e Continuar pelo teclado só com nome válido; depende de T012.
- [X] T014 [P] [US1] Implementar `ios/Capia/Sources/Capia/Setup/GoalsStepView.swift` com "{Primeiro nome}, o que te trouxe aqui?" e as quatro opções de seleção múltipla com caixa 26 × 26 e estado anunciado; depende de T012.
- [X] T015 [US1] Executar no iPhone o teste independente da US1 e as linhas Entrada, Nome e Objetivos de `specs/002-initial-setup/quickstart.md`, com VoiceOver, texto ampliado, redução de movimento e comparação com as etapas 1–2 do quadro; registrar em `specs/002-initial-setup/validation.md`, atualizar este arquivo e commitar só a US1.

Execução: textos, dicas, rótulos e poses ficam em `ios/Capia/Sources/Capia/Setup/SetupCopy.swift`,
reutilizado pelas próximas US.

**Checkpoint**: Nome e objetivos finais; as demais etapas ainda podem ser provisórias.

## Phase 4: User Story 2 - Cadastrar a primeira conta com saldo inicial (Priority: P1)

**Goal**: Etapas de conta e saldo com centavos exatos.
**Branch**: `feat/002-initial-setup-us2-account`, atualizada com a US1.
**Independent Test**: Escolher cada tipo, validar o nome, digitar e apagar o saldo, usar os
atalhos e avançar com zero até a pergunta do cartão.

- [ ] T016 [P] [US2] Implementar `ios/Capia/Sources/Capia/Setup/AccountStepView.swift`: grade de três tipos com ícones desenhados a partir dos traços SVG do quadro (research §5), rótulo do campo conforme o tipo, placeholder "Ex.: Banco Aurora", sem autocorreção, foco automático e "Você pode adicionar outras contas depois."; ícones decorativos para VoiceOver.
- [ ] T017 [P] [US2] Implementar `ios/Capia/Sources/Capia/Setup/BalanceStepView.swift`: "Quanto tem hoje em {conta}?", valor central em Zen Maru Gothic cinza quando zero, teclado numérico com a conversão de `Money` (digitar e apagar da direita), atalhos `+ R$ 500`, `+ R$ 1.000`, `+ R$ 2.500` em pílulas 44 pt e o texto de apoio; valor anunciado em reais.
- [ ] T018 [US2] Executar no iPhone as linhas Conta e Saldo de `specs/002-initial-setup/quickstart.md`, teclado aberto, VoiceOver e texto ampliado, comparando com as etapas 3–4 do quadro; registrar em `specs/002-initial-setup/validation.md`, atualizar este arquivo e commitar só a US2; depende de T016–T017.

**Checkpoint**: Conta e saldo finais; cartão e conclusão podem seguir provisórios.

## Phase 5: User Story 3 - Separar o cartão de crédito da conta (Priority: P1)

**Goal**: Pergunta do cartão e datas com validação e aviso do design.
**Branch**: `feat/002-initial-setup-us3-card`, atualizada com a US2.
**Independent Test**: "Agora não" chega à conclusão sem datas; "Sim" mostra as datas, bloqueia
dias iguais e conclui com dias diferentes.

- [ ] T019 [P] [US3] Implementar `ios/Capia/Sources/Capia/Setup/CardQuestionStepView.swift` com as duas opções de 76 pt, ícones de cartão e círculo desenhados a partir do quadro, títulos e subtítulos exatos e estado selecionado anunciado.
- [ ] T020 [P] [US3] Implementar `ios/Capia/Sources/Capia/Setup/CardDatesStepView.swift`: "Datas do cartão {conta}", fileiras horizontais de 1 a 31 (48 × 52, "Dia N") rolando até o selecionado, aviso verde com o dia de fechamento ou erro com tremor (omitido com redução de movimento) quando os dias coincidem.
- [ ] T021 [US3] Executar no iPhone as linhas Sem cartão, Com cartão e Voltar de `specs/002-initial-setup/quickstart.md`, com VoiceOver na rolagem de dias e texto ampliado, comparando com as etapas 5–6 do quadro; registrar, atualizar este arquivo e commitar só a US3; depende de T019–T020.

**Checkpoint**: Todas as seis etapas finais; conclusão ainda provisória.

## Phase 6: User Story 4 - Concluir e revisar o espaço configurado (Priority: P2)

**Goal**: Conclusão com comemoração, resumo acumulado, nova conta, destino do mês e reabertura.
**Branch**: `feat/002-initial-setup-us4-done`, atualizada com a US3.
**Independent Test**: Concluir com e sem cartão, adicionar e cancelar outra conta, ir ao mês e
voltar, encerrar e reabrir o app, e interromper uma configuração antes do fim.

- [ ] T022 [US4] Implementar `ios/Capia/Sources/Capia/Setup/SetupDoneView.swift`: fundo `#F1E8DA`, 18 confetes que caem uma vez (ocultos ao VoiceOver e omitidos com redução de movimento), capivara comemorando 180 pt, "Tudo pronto, {primeiro nome}!", texto de apoio, cartão de resumo com cada conta e cada cartão ("Separado") ou "Sem cartão por enquanto.", "Ver meu mês", "Adicionar outra conta", Voltar só com rascunho e aviso de falha de gravação com "Tentar de novo".
- [ ] T023 [P] [US4] Finalizar `ios/Capia/Sources/Capia/Setup/MonthPlaceholderView.swift` no padrão visual da antiga entrada provisória, com "O resumo do seu mês vem na próxima etapa do protótipo." e "Voltar ao resumo", foco no título.
- [ ] T024 [US4] Conferir em `ios/Capia/Sources/Capia/AppRootView.swift` a gravação ao concluir e ao repetir a conclusão, a abertura no mês com espaço guardado, a restauração do resumo e a ausência de gravação de configurações interrompidas; executar `swift test --package-path ios/CapiaFlow`; depende de T022–T023.
- [ ] T025 [US4] Executar no iPhone as linhas Outra conta, Cancelar outra conta, Ver meu mês, Reabertura, Interrupção e Toques rápidos de `specs/002-initial-setup/quickstart.md`, com VoiceOver e redução de movimento na conclusão; registrar SC-004, SC-005 e SC-008, atualizar este arquivo e commitar só a US4.

**Checkpoint**: Fluxo completo e gravação no aparelho verificados. Avançar a base por
fast-forward até a ponta da US4.

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T026 Na branch base, executar `python scripts/prepare-design-assets.py --check`, `swift test --package-path ios/CapiaFlow` e `xtool dev build` em `ios/Capia/`, inspecionar o bundle (imagens, fontes, ícone) e registrar em `specs/002-initial-setup/validation.md`; correções de uma US vão em commit com o prefixo dela.
- [ ] T027 Executar integralmente `specs/002-initial-setup/quickstart.md` no iPhone sem rede, com VoiceOver, redução de movimento, maior texto e comparação com o quadro; registrar SC-001 a SC-008, aparelho, iOS, revisão e pendências em `specs/002-initial-setup/validation.md`.
- [ ] T028 Atualizar `README.md`, `docs/prototipo.md` e `specs/002-initial-setup/spec.md` (status) com o estado real; conferir conformidade com `specs/002-initial-setup/contracts/initial-setup-ui.md`, marcar só as tarefas comprovadas e fazer o commit de integração na base, sem merge em `master`.

## Dependencies & Execution Order

```text
Planejamento (spec, plano, emenda 1.1.0)
  → Base: T001–T002 (recurso e registro)
  → Base: T003–T010 (comportamento testado, gravação, esqueleto compilável)
  → US1: T011–T015 (contêiner, nome, objetivos — MVP)
  → US2: T016–T018 (conta e saldo)
  → US3: T019–T021 (cartão e datas)
  → US4: T022–T025 (conclusão, mês, reabertura)
  → Base: T026–T028 (validação integrada)
```

- US1 depende da base. US2 e US3 usam o contêiner e o tema da US1. US4 precisa das seis
  etapas finais para o percurso completo. Execução sequencial, uma branch por vez.
- Cada US tem teste independente do que entrega, mas não base de código isolada.
- Não começar a história seguinte com a validação da anterior pendente.

### Parallel Opportunities

Doze tarefas marcadas `[P]`, condicionadas aos pré-requisitos:

- Setup: T001 e T002.
- Base: T003, T004 e T007 (após T004) em arquivos distintos; T005 aguarda T003–T004.
- US1: T013 e T014 após T012.
- US2: T016 e T017. US3: T019 e T020. US4: T023 durante T022.

### Parallel Example: User Story 1

Depois de T012, implementar `NameStepView.swift` (T013) e `GoalsStepView.swift` (T014) ao
mesmo tempo; nenhum dos dois edita `SetupView.swift`, que já os referencia como provisórios.

## Implementation Strategy

### Rastreabilidade dos requisitos

| Escopo | Requisitos | Tarefas |
|--------|------------|---------|
| Base | FR-001, FR-002, FR-005, FR-008, FR-011, FR-013, FR-014, FR-019 | T001–T010 |
| US1 | FR-003, FR-004, FR-005, FR-006, FR-015, FR-016, FR-017, FR-018 | T011–T015 |
| US2 | FR-007, FR-008, FR-015, FR-016, FR-017 | T016–T018 |
| US3 | FR-009, FR-016, FR-017, FR-018 | T019–T021 |
| US4 | FR-010, FR-011, FR-012, FR-014, FR-017, FR-018 | T022–T025 |
| Integração | FR-001 a FR-019, SC-001 a SC-008 | T026–T028 |

### MVP First

Base (T001–T010) e US1 (T011–T015): a pessoa sai da apresentação, informa nome e objetivos
no visual final e segue pelo restante em telas provisórias que já gravam e reabrem.

### Incremental Delivery

Cada US entra por fast-forward sobre a anterior, com commit revisável e resultado
observável no iPhone. Depois da US4, integrar na base e executar o quickstart completo.
Não criar backend, serviços vazios ou regras de fatura para completar esta lista.

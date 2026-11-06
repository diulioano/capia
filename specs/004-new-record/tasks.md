# Tasks: Novo registro digitado

**Input**: `specs/004-new-record/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/new-record-ui.md](contracts/new-record-ui.md)
e [quickstart.md](quickstart.md).

**Tests**: XCTest em `ios/CapiaFlow` cobre registro, data, sugestão de categoria, fatura,
parcelas, totais e listas do Início, estado do registro, raiz e leitura de espaços antigos.
Interface, acessibilidade e reabertura são validadas no iPhone. TDD não é obrigatório.

**Organization**: Base compartilhada; depois US1, US2, US3, US4 e US5. Marcar uma tarefa
somente após cumprir seu resultado observável.

## Format: `[ID] [P?] [Story] Description`

`[P]` permite trabalho em arquivos diferentes após os pré-requisitos.

## Path Conventions

- App: `ios/Capia/Sources/Capia/` (nova tela em `Record/`).
- Comportamento puro e testes: `ios/CapiaFlow/`.
- Referência: `design/App de finanças onsen — protótipo iPhone.html`, quadros `f5b9b259-abfa-43b6-993e-a9dc8456c772` (Novo registro) e `333f2428-5004-43ff-b703-276a4524089b` (Resumo do mês).
- Evidências: `specs/004-new-record/validation.md`.

## Branches e commits por US

Mesma regra das funcionalidades anteriores (AGENTS.md). Commits com o e-mail
`vargasdasilveiradiuliano@gmail.com`, configurado no repositório em 2026-11-06.

| Etapa | Branch | Recebe antes de começar | Commit de referência |
|-------|--------|------------------------|----------------------|
| Planejamento e base | `feat/004-new-record` | `master` | `chore(record-base): cria registro, fatura, estado e esqueleto do novo registro` |
| US1: gasto digitado | `feat/004-new-record-us1-expense` | Base com T001–T010 | `feat(us1): adiciona teclado, formulário de gasto e registros no Início` |
| US2: receita digitada | `feat/004-new-record-us2-income` | US1 | `feat(us2): adiciona receita digitada` |
| US3: cartão e parcelas | `feat/004-new-record-us3-card` | US2 | `feat(us3): adiciona gasto no cartão, parcelas e fatura aberta` |
| US4: desfazer e desistir | `feat/004-new-record-us4-undo` | US3 | `feat(us4): adiciona desfazer, expiração do aviso e falha de gravação` |
| US5: Falar e Foto | `feat/004-new-record-us5-modes` | US4 | `feat(us5): adiciona avisos provisórios de Falar e Foto` |
| Validação integrada | `feat/004-new-record` | US5 | `chore(validation): valida novo registro no iPhone` |

Cada US atualiza sua branch com `git merge --ff-only` da predecessora. Sem reset nem
force-push. Sem aparelho, salvar como `wip(usN): ...` e manter a validação aberta. As US são
encadeadas, apesar de US3–US5 dependerem tecnicamente só da US1, porque mexem nos mesmos
arquivos de tela (`RecordFormView.swift`, `NewRecordView.swift`).

## Phase 1: Setup

- [X] T001 Criar `specs/004-new-record/validation.md` com branch, revisão de partida (`master` `1d239e5`), versões e seções pendentes para base, US1–US5 e integração.

## Phase 2: Foundational

**Purpose**: modelo, regras e estado testados no Linux; esqueleto que compila. Bloqueia todas as US.

- [X] T002 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/Record.swift` com `Record` (`maxAmount`, nome exibido, validação), `RecordKind`, `RecordCategory` (ordem do quadro, `suggestion(for:)` por início de palavra sem caixa nem acentos, research §7), `PaymentSource` e `CalendarDay` (hoje e ontem pelo fuso, comparação); testar em `ios/CapiaFlow/Tests/CapiaFlowTests/RecordTests.swift` limites de valor e descrição, nome exibido, gasto sem categoria inválido, receita em cartão inválida, cada regra de sugestão, "Café"/"CAFÉ", "99", "bar" vs "barato", sem correspondência, e virada de dia no fuso.
- [X] T003 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/CardBilling.swift` com `Invoice`, fechamento efetivo, fatura da compra, fatura aberta e `Record.installments(card:)` (research §4–5); testar em `CardBillingTests.swift` compra antes, no e depois do fechamento, fechamento 31 em mês curto e em fevereiro, vencimento no mês seguinte (fecha 25, vence 5), virada de ano, 3× com resto (R$ 100,00 → 33,34/33,33/33,33), soma exata em 1…12×, mês de cada parcela e fatura aberta no dia do fechamento.
- [X] T004 Acrescentar `records` a `ConfiguredSpace` em `ios/CapiaFlow/Sources/CapiaFlow/Space.swift` (`decodeIfPresent`, `adding(_:)`, `removing(id:)`), remover `accountsTotal` e acompanhar os registros no espaço de `SetupFlow.swift` (como `recordSalaryReceipt`); testar em `SpaceStoreTests.swift` espaço gravado sem `records`, ida e volta com registros e `schemaVersion` 1; depende de T002.
- [X] T005 Estender `ios/CapiaFlow/Sources/CapiaFlow/MonthSummary.swift`: totais com receitas, gastos em conta e parcelas do mês; `bill` pelas faturas abertas; `accountsBalance: Int64`; `expenseBreakdown`, `incomeBreakdown`, `recent` (5) e `hasRecords` (data-model.md); testar em `MonthSummaryTests.swift` saldo inicial fora dos totais, gasto no cartão fora do dinheiro em contas, conta negativa, registro de mês anterior, 2ª parcela no mês seguinte, recente com total da compra, empate de categorias, ordem por dia e `savedAt`, salário na lista e fonte inexistente ignorada; depende de T003–T004.
- [X] T006 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/RecordFlow.swift` com `RecordMode`, `RecordPhase`, `DateChoice`, `RecordDraft`, `SavedToast` e as ações de data-model.md; testar em `RecordFlowTests.swift` estado inicial, teclado (dígito, 00, apagar, limite), Continuar só com valor, voltar preservando, sugestão sem sobrepor escolha, `canSave` de gasto e receita, receita sem cartões, parcelas 1…12 e zeradas ao trocar para conta, troca de aba preservando tipo e valor, `makeRecord` com hoje/ontem/outra data, `didSave` zerando, `saveDidFail` preservando e `undo` restaurando; depende de T002.
- [X] T007 Trocar `showingNewRecord` de `HomeFlow.swift` por `AppFlow.record: RecordFlow?` em `AppFlow.swift`, com `send(RecordAction)`, `commitRecord(_:)`, `undoLastRecord()` e fechar sem salvar; atualizar `HomeFlowTests.swift` e `AppFlowTests.swift` (abrir sem empilhar, fontes do espaço, commit no espaço da sessão, desfazer, fechar descarta, falha não altera o espaço); executar `swift test`; depende de T004–T006.
- [X] T008 [P] Acrescentar a `ios/Capia/Sources/Capia/Setup/CentsField.swift` um limite de algarismos opcional (padrão 11), sem mudar a configuração.
- [X] T009 [P] Acrescentar a `ios/Capia/Sources/Capia/Design/CapiaTheme.swift` as cores das categorias, das receitas e do aviso (contrato) e criar `ios/Capia/Sources/Capia/Record/RecordCopy.swift` com nomes de categorias e fontes e os textos fixos.
- [X] T010 Criar `ios/Capia/Sources/Capia/Record/NewRecordView.swift` provisória (texto e botões simples ligados a `RecordFlow`), sobrepor em `HomeView.swift`, tirar o novo registro de `PlaceholderTabView.swift`, fazer `AppRootView.swift` gravar antes de `commitRecord` e adaptar `BalanceCardView.swift` a `accountsBalance` com sinal; compilar com `xtool dev build`, registrar em `validation.md` e fazer o commit da base; depende de T007–T009.

**Checkpoint**: testes passam; o app compila; + abre o registro provisório, que salva e aparece nos totais.

## Phase 3: User Story 1 - Registrar um gasto digitado (P1) 🎯 MVP

**Goal**: gasto em conta do + ao Início, guardado e visível após reabrir.

**Independent Test**: linhas Abrir, Teclado, Sugestão, Gasto em conta, Reabertura, Voltar e fechar e Data de `quickstart.md`.

**Branch**: `feat/004-new-record-us1-expense`.

- [ ] T011 [US1] Finalizar o cabeçalho de `NewRecordView.swift` (fechar 44 × 44, título por fase, abas com ícones desenhados do quadro e seleção anunciada, entrada `.enter` omitida com redução de movimento) e ocultar o Início para o VoiceOver enquanto o registro está aberto.
- [ ] T012 [US1] Criar `ios/Capia/Sources/Capia/Record/AmountPadView.swift` com o seletor de tipo (só Gasto ativo nesta US), pergunta, valor com salto e cursor piscando, teclado 3 × 4 com nomes acessíveis, valor anunciado a cada tecla e Continuar ativo/inativo; estático com redução de movimento.
- [ ] T013 [US1] Criar `ios/Capia/Sources/Capia/Record/RecordFormView.swift` para gasto em conta: capivara pensativa/feliz, valor em `CentsField` (8 algarismos) com erro de zero, descrição (60 caracteres), fichas de categoria com "· sugerido", "Pago com" com as contas, data Hoje/Ontem/Outra data com calendário gráfico em folha até hoje, barra Voltar/Salvar acima da área segura e rolagem com texto ampliado.
- [ ] T014 [US1] Criar `ios/Capia/Sources/Capia/Record/RecordToastView.swift` com "Registro salvo", capivara comemorando e subtítulo do contrato, anunciado ao aparecer, sem Desfazer nesta US; zerar o teclado após salvar e impedir registro duplicado em toques repetidos.
- [ ] T015 [US1] Mostrar gastos no Início em `MonthSectionsView.swift` ("Para onde foi" › Gastos com barra, cores e percentuais; "Registros recentes" com inicial, subtítulo e "− R$"; valores ocultos) e o balão com registros em `HomeCopy.swift`/`MonthView.swift`.
- [ ] T016 [US1] Validar no iPhone as linhas da US1 de `quickstart.md`, com VoiceOver, texto ampliado e redução de movimento; registrar e commitar só a US1.

## Phase 4: User Story 2 - Registrar uma receita digitada (P1)

**Goal**: receita em conta nas receitas do mês.

**Independent Test**: linhas Receita e Receita sem descrição de `quickstart.md`.

**Branch**: `feat/004-new-record-us2-income`.

- [ ] T017 [US2] Ativar Receita em `AmountPadView.swift` (cores do contrato, "Quanto você recebeu?", valor preservado ao trocar) e adaptar `RecordFormView.swift` (subtítulo de receita, "Entrou em" só com contas, sem categorias) e o subtítulo "+ R$" do aviso.
- [ ] T018 [US2] Mostrar receitas em `MonthSectionsView.swift` ("Para onde foi" › Receitas pelo nome, salário como "Salário"; recentes "+ R$" em verde) e conferir o selo do saldo com receitas avulsas.
- [ ] T019 [US2] Validar no iPhone as linhas da US2 de `quickstart.md`, com VoiceOver; registrar e commitar só a US2.

## Phase 5: User Story 3 - Gastar no cartão, à vista ou parcelado (P2)

**Goal**: compra no cartão com parcelas, sem mexer no dinheiro em contas, e fatura aberta no Início.

**Independent Test**: linhas Cartão à vista, Parcelado, Resto, Troca de fonte e Sem cartão de `quickstart.md`.

**Branch**: `feat/004-new-record-us3-card`.

- [ ] T020 [US3] Acrescentar os cartões a "Pago com" e o bloco Parcelas em `RecordFormView.swift` ("Menos parcelas"/"Mais parcelas" desabilitados nos limites, valor anunciado, texto "À vista, na fatura de {mês}" ou "n× de R$ · até {mês}" vindo de `CardBilling`, entrada `.fade` omitida com redução de movimento).
- [ ] T021 [US3] No Início, ligar o indicador Fatura a `totals.bill` e mostrar "n×" e "Cartão {nome}" nos recentes em `MonthSectionsView.swift`.
- [ ] T022 [US3] Validar no iPhone as linhas da US3 de `quickstart.md`, com espaço com e sem cartão; registrar e commitar só a US3.

## Phase 6: User Story 4 - Desfazer ou desistir de um registro (P2)

**Goal**: corrigir pelo aviso e sair sem deixar rastro.

**Independent Test**: linhas Desfazer, Aviso expira e Voltar e fechar de `quickstart.md`.

**Branch**: `feat/004-new-record-us4-undo`.

- [ ] T023 [US4] Acrescentar "Desfazer" a `RecordToastView.swift` e o caminho em `AppRootView.swift` (gravar o espaço sem o registro, depois `undoLastRecord()`); expirar o aviso em 4,2 s, mantê-lo com VoiceOver até a próxima ação e descartar aviso e rascunho ao fechar.
- [ ] T024 [US4] Mostrar o aviso de falha ("Não deu para salvar agora. Tente de novo." e "Tentar de novo") ao falhar a gravação do registro ou do desfazer, preservando o formulário; cobrir em `AppFlowTests.swift`.
- [ ] T025 [US4] Validar no iPhone as linhas da US4 de `quickstart.md`, inclusive reabertura após desfazer; registrar a falha de gravação como coberta só por testes; commitar só a US4.

## Phase 7: User Story 5 - Saber que Falar e Foto ainda vêm (P3)

**Goal**: abas completas, sem simulação nem permissões.

**Independent Test**: linha Falar e Foto de `quickstart.md`.

**Branch**: `feat/004-new-record-us5-modes`.

- [ ] T026 [US5] Criar `ios/Capia/Sources/Capia/Record/RecordModePlaceholderView.swift` (capivara calma 150, texto de Falar ou Foto, botão "Digitar") e ligá-la às abas em `NewRecordView.swift`, voltando ao teclado com tipo e valor.
- [ ] T027 [US5] Validar no iPhone a linha Falar e Foto de `quickstart.md`, confirmando que nenhuma permissão é pedida; registrar e commitar só a US5.

## Phase 8: Validação integrada

- [ ] T028 Integrar as US1–US5 na base, executar `quickstart.md` completo no iPhone (incluindo Toques rápidos e Ocultar), comparar com os quadros "Novo registro" e "Resumo do mês" com registros, registrar adaptações, atualizar `docs/prototipo.md` e o status da spec; commitar.

## Dependencies & Execution Order

- **Setup (T001)** → **Base (T002–T010)** → US1 → US2 → US3 → US4 → US5 → **Validação (T028)**.
- Dentro da base: T002 e T003 em paralelo; T004 depende de T002; T005 de T003–T004; T006 de T002; T007 de T004–T006; T008 e T009 em paralelo a qualquer momento; T010 por último.
- Dentro de cada US, a validação no iPhone é a última tarefa e fecha o commit da US.

### Parallel Opportunities

```text
Base:  T002 Record.swift  ‖  T003 CardBilling.swift  ‖  T008 CentsField  ‖  T009 Theme/Copy
       depois T006 RecordFlow.swift ‖ T004 Space.swift
```

As US não rodam em paralelo: compartilham `RecordFormView.swift`, `NewRecordView.swift` e
`MonthSectionsView.swift`.

## Implementation Strategy

1. **MVP**: base + US1. Já permite registrar gastos em conta e vê-los no Início; validar no iPhone antes de seguir.
2. **Incremental**: US2 (receitas) e US3 (cartão) completam os significados financeiros; US4 dá correção; US5 fecha a composição do quadro.
3. A validação integrada confere o Início com registros, que ficou pendente na 003.

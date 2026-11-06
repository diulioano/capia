# Tasks: Resumo do mês

**Input**: `specs/003-month-summary/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/month-summary-ui.md](contracts/month-summary-ui.md)
e [quickstart.md](quickstart.md).

**Tests**: XCTest em `ios/CapiaFlow` cobre totais, sinal, saudação, mês, estado do Início e
raiz. Interface, acessibilidade e reabertura são validadas no iPhone. TDD não é obrigatório.

**Organization**: Base compartilhada; depois US1, US2, US3 e US4. Marcar uma tarefa somente
após cumprir seu resultado observável.

## Format: `[ID] [P?] [Story] Description`

`[P]` permite trabalho em arquivos diferentes após os pré-requisitos.

## Path Conventions

- App: `ios/Capia/Sources/Capia/` (novas telas em `Home/`).
- Comportamento puro e testes: `ios/CapiaFlow/`.
- Referência: `design/App de finanças onsen — protótipo iPhone.html`, quadro `333f2428-5004-43ff-b703-276a4524089b`.
- Evidências: `specs/003-month-summary/validation.md`.

## Branches e commits por US

Mesma regra das funcionalidades anteriores (AGENTS.md). Commits com o e-mail
`vargasdasilveiradiuliano@gmail.com`, configurado no repositório em 2026-11-06.

| Etapa | Branch | Recebe antes de começar | Commit de referência |
|-------|--------|------------------------|----------------------|
| Planejamento e base | `feat/003-month-summary` | `master` | `chore(month-base): cria cálculo, estado e esqueleto do Início` |
| US1: ver o mês | `feat/003-month-summary-us1-overview` | Base com T001–T007 | `feat(us1): adiciona cabeçalho, saldo, indicadores e capivara` |
| US2: seções | `feat/003-month-summary-us2-sections` | US1 | `feat(us2): adiciona seções do mês com estados vazios` |
| US3: ocultar | `feat/003-month-summary-us3-hide-values` | US2 | `feat(us3): adiciona ocultar valores` |
| US4: navegação | `feat/003-month-summary-us4-navigation` | US3 | `feat(us4): adiciona barra, botão +, contas e metas` |
| Validação integrada | `feat/003-month-summary` | US4 | `chore(validation): valida resumo do mês no iPhone` |

Cada US atualiza sua branch com `git merge --ff-only` da predecessora. Sem reset nem
force-push. Sem aparelho, salvar como `wip(usN): ...` e manter a validação aberta.

## Phase 1: Setup

- [X] T001 Criar `specs/003-month-summary/validation.md` com branch, revisão, versões e seções pendentes para base, US1–US4 e integração.

## Phase 2: Foundational

- [X] T002 [P] Acrescentar `BRL.format(signed:)` e `BRL.hidden` em `ios/CapiaFlow/Sources/CapiaFlow/Money.swift`, com testes em `MoneyTests.swift` (zero sem sinal, `− R$ 23,50`, limite).
- [X] T003 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/MonthSummary.swift` com `MonthTotals`, `MonthCalendar` e `MonthSummary` (data-model.md, research §2–3); testar em `MonthSummaryTests.swift` saldo e sobra com sinal, parcela arredondada e limitada, nível 18–80%, ausência de receitas, saldo inicial fora dos totais, saudação nas fronteiras de horário e fuso, os doze meses e primeiro nome.
- [X] T004 [P] Criar `ios/CapiaFlow/Sources/CapiaFlow/HomeFlow.swift` com `HomeTab`, `CategoryTab`, `HomeAction` e `HomeFlow`; testar em `HomeFlowTests.swift` valores iniciais, abas, Fatura, ocultar e destino de novo registro sem empilhar.
- [X] T005 Trocar `month` por `home` em `ios/CapiaFlow/Sources/CapiaFlow/AppFlow.swift`, com `send(_: HomeAction)`, `addAnotherAccountFromHome()` e `space`; remover `returnFromMonth`; atualizar `AppFlowTests.swift` (conclusão → Início, reabertura no Início, outra conta a partir de Contas grava e volta ao Início, valores ocultos preservados na sessão); executar `swift test`; depende de T003–T004.
- [X] T006 Extrair a lista de contas e cartões de `SetupDoneView.swift` para `ios/Capia/Sources/Capia/Setup/SpaceSummaryList.swift` sem mudar a conclusão.
- [X] T007 Criar `ios/Capia/Sources/Capia/Home/HomeView.swift` provisória (abas, +, destinos em texto simples ligados a `HomeFlow`), ligar em `AppRootView.swift`, remover `MonthPlaceholderView.swift`; compilar com `xtool dev build`, registrar em `validation.md` e fazer o commit da base; depende de T005–T006.

**Checkpoint**: testes passam; o app compila e todos os destinos respondem.

## Phase 3: User Story 1 - Ver o mês ao abrir o app (P1) 🎯 MVP

**Branch**: `feat/003-month-summary-us1-overview`.

- [X] T008 [US1] Acrescentar em `ios/Capia/Sources/Capia/Design/CapiaTheme.swift` as cores do quadro (água `#9CC7BA`, espuma `#BEDCD2`, divisória `#F4EBDC`, chip de gasto `#FBE3CF`, barra `#F6F0E6`, selo `#FFFDF8`, texto `#3E3A34`).
- [X] T009 [US1] Criar `ios/Capia/Sources/Capia/Home/BalanceCardView.swift`: cartão 214 pt, água no nível, ondas e vapor animados, contagem do valor, selo e leitura acessível única; tudo estático com redução de movimento.
- [X] T010 [US1] Criar `ios/Capia/Sources/Capia/Home/MonthView.swift` e `HomeCopy.swift` com cabeçalho (saudação, mês, olho visual), cartão do saldo, indicadores (Fatura como botão; "Sem cartão"; coluna única com texto ampliado) e capivara calma com balão; recalcular saudação e mês ao voltar ao primeiro plano; depende de T008–T009.
- [X] T011 [US1] Validar no iPhone as linhas Entrada, Reabertura, Cabeçalho, Saldo, Indicadores e Capivara de `quickstart.md`, com VoiceOver, texto ampliado e redução de movimento; registrar e commitar só a US1.

## Phase 4: User Story 2 - Seções do mês sem registros (P1)

**Branch**: `feat/003-month-summary-us2-sections`.

- [X] T012 [US2] Criar `ios/Capia/Sources/Capia/Home/MonthSectionsView.swift` com "Previstos para este mês", "Para onde foi" (abas Gastos/Receitas ligadas a `HomeFlow`, barra vazia) e "Registros recentes", com os estados vazios do contrato; inserir em `MonthView.swift`.
- [X] T013 [US2] Validar no iPhone a linha Seções de `quickstart.md`, com VoiceOver e texto ampliado; registrar e commitar só a US2.

## Phase 5: User Story 3 - Ocultar os valores (P2)

**Branch**: `feat/003-month-summary-us3-hide-values`.

- [X] T014 [US3] Ligar o olho a `toggleValuesHidden` e aplicar `BRL.hidden` a todos os valores do Início, ao selo e às leituras acessíveis ("valor oculto"), com estado do botão anunciado.
- [ ] T015 [US3] Validar no iPhone a linha Ocultar de `quickstart.md`, com VoiceOver; registrar e commitar só a US3.

## Phase 6: User Story 4 - Navegar a partir do Início (P2)

**Branch**: `feat/003-month-summary-us4-navigation`.

- [ ] T016 [US4] Finalizar em `HomeView.swift` a barra inferior (ícones desenhados do quadro, aba atual anunciada) e o botão + (posição, sombra, entrada com giro omitida com redução de movimento), sem cobrir o conteúdo.
- [ ] T017 [P] [US4] Criar `ios/Capia/Sources/Capia/Home/AccountsTabView.swift` com `SpaceSummaryList`, aviso provisório e "Adicionar outra conta" ligado à raiz.
- [ ] T018 [P] [US4] Criar `ios/Capia/Sources/Capia/Home/PlaceholderTabView.swift` para Metas e novo registro, com "Voltar ao início" no novo registro.
- [ ] T019 [US4] Validar no iPhone as linhas Novo registro, Contas, Outra conta, Metas e Toques rápidos de `quickstart.md`; registrar e commitar só a US4.

## Phase 7: Validação integrada

- [ ] T020 Integrar as US na base, executar `quickstart.md` completo no iPhone, comparar com o quadro, atualizar `docs/prototipo.md` e o status da spec; commitar.

# Implementation Plan: Novo registro digitado

**Branch**: `feat/004-new-record` | **Date**: 2026-11-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-new-record/spec.md`

A branch base `feat/004-new-record` parte de `master` (`1d239e5`), que já integra o Get
Started, a configuração inicial e o resumo do mês validados. As branches por US serão
definidas em `tasks.md`.

## Summary

Trocar o destino provisório de "Adicionar registro" pela aba Digitar do quadro "Novo
registro": teclado de valor, tipo Gasto ou Receita, formulário com descrição, categoria
sugerida, conta ou cartão, parcelas e data, aviso "Registro salvo" com "Desfazer" e avisos
provisórios em Falar e Foto. Os registros são guardados no `space.json` e passam a alimentar
o Início: totais do mês, fatura aberta, dinheiro em contas com sinal, "Para onde foi" e
"Registros recentes". Regras de dinheiro, fatura, parcelas, sugestão de categoria e o estado
do registro ficam em código puro testável no Linux; `ios/Capia` desenha e liga eventos. A
gravação acontece antes de confirmar o registro na sessão.

## Technical Context

**Language/Version**: Swift 6.4.2 no Ubuntu do WSL; manifestos Swift tools 6.0, modo Swift 6.

**Primary Dependencies**: SwiftUI, UIKit (só no `CentsField` existente) e Foundation do SDK;
Swift Package Manager; xtool 1.24.0. Sem bibliotecas de terceiros.

**Storage**: `space.json`, `schemaVersion: 1`, com a chave nova `records` lida com
`decodeIfPresent` ([research §1](research.md)). Estado do registro só em memória.

**Testing**: XCTest em `ios/CapiaFlow` para `Record`, `CalendarDay`, sugestão de categoria,
`CardBilling`, parcelas, totais e listas do Início, `RecordFlow`, raiz (gravar, desfazer,
falha) e leitura de espaços antigos. Validação manual no iPhone para interface, VoiceOver,
Dynamic Type, redução de movimento e reabertura.

**Target Platform**: iPhone, iOS 17 ou posterior. Aparelho validado: "Gremio", iPhone15,2.

**Project Type**: App móvel nativo: pacote do app `ios/Capia` e pacote puro `ios/CapiaFlow`.

**Performance Goals**: Cada tecla e cada salvamento respondem sem atraso perceptível; nenhuma
ação espera animação. Gravar regrava o JSON inteiro, adequado a centenas de registros.

**Constraints**: Offline; sem permissões (nem em Falar e Foto). Centavos inteiros (`Int64`),
sem `Double` em valores. Datas como dia do calendário no fuso do aparelho. Formato pt-BR e
nomes de meses determinísticos no Linux e no iPhone. Alvos de toque de 44 × 44 pontos.

**Scale/Scope**: Uma tela com duas fases e dois avisos, cinco US, 20 requisitos funcionais;
Início alterado em três seções e no cartão do saldo.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Princípio | Antes da pesquisa | Após o desenho da solução |
|-----------|-------------------|---------------------------|
| I. Nativo e compilação comprovada | Conforme: cadeia xtool validada em 001–003 | Conforme: nenhuma dependência nova |
| II. Design e acessibilidade | Conforme: quadro "Novo registro" identificado (`f5b9b259…`) | Conforme: [contrato](contracts/new-record-ui.md) mapeia cada elemento; complementos registrados (Falar e Foto, receita sem categoria, calendário, falha de gravação) |
| III. Domínio financeiro | Conforme: conta e cartão distintos; parcela no mês; total no detalhe | Conforme: gasto no cartão não altera dinheiro em contas; fatura à parte do saldo; parcelas somam o total; saldo inicial fora dos totais; testes em `CardBillingTests` e `MonthSummaryTests` |
| IV. Protótipo antes de integrações | Conforme: sem reconhecimento simulado nem servidor; registros reais da pessoa guardados no aparelho, como o espaço (permitido pelo princípio) | Conforme: Falar e Foto não simulam nem pedem permissões |
| V. Estrutura e entregas verificáveis | Conforme: modelo, fatura e estado antes da interface | Conforme: unidades separam comportamento e interface |

Sem violações. A regra de fechamento da fatura é premissa do protótipo e fica explícita como
tal, sem alterar as questões abertas de `docs/descoberta.md`.

## Project Structure

### Documentation (this feature)

```text
specs/004-new-record/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
├── contracts/new-record-ui.md
├── tasks.md              # $speckit-tasks
└── validation.md         # criado na implementação
```

### Source Code (repository root)

Arquivos novos (+), alterados (~) e removidos (−) previstos:

```text
ios/
├── Capia/Sources/Capia/
│   ├── AppRootView.swift                 ~ grava antes de confirmar; desfazer; falha
│   ├── Design/CapiaTheme.swift           ~ cores das categorias e do aviso
│   ├── Record/
│   │   ├── NewRecordView.swift           + contêiner: fechar, título, abas, aviso
│   │   ├── AmountPadView.swift           + US1/US2: tipo, valor, cursor, teclado, Continuar
│   │   ├── RecordFormView.swift          + US1–US3: capivara, campos, parcelas, data, ações
│   │   ├── RecordToastView.swift         + US1/US4: "Registro salvo", Desfazer, falha
│   │   ├── RecordModePlaceholderView.swift + US5: Falar e Foto
│   │   └── RecordCopy.swift              + textos, nomes de categorias e fontes
│   ├── Home/
│   │   ├── HomeView.swift                ~ sobrepõe NewRecordView no lugar do destino provisório
│   │   ├── PlaceholderTabView.swift      ~ sem o caso de novo registro
│   │   ├── MonthSectionsView.swift       ~ categorias, receitas e recentes com registros
│   │   ├── BalanceCardView.swift         ~ "Em contas hoje" com sinal
│   │   └── HomeCopy.swift                ~ balão com registros
│   └── Setup/CentsField.swift            ~ limite de algarismos configurável
└── CapiaFlow/
    ├── Sources/CapiaFlow/
    │   ├── Record.swift                  + Record, RecordKind, RecordCategory, PaymentSource, CalendarDay
    │   ├── CardBilling.swift             + fatura, fatura aberta, parcelas
    │   ├── RecordFlow.swift              + estado e ações do registro
    │   ├── Space.swift                   ~ records; adding/removing; remove accountsTotal
    │   ├── MonthSummary.swift            ~ totais com registros, listas, saldo em contas com sinal
    │   ├── HomeFlow.swift                ~ sem showingNewRecord
    │   ├── SetupFlow.swift               ~ acompanha registros no espaço da sessão
    │   └── AppFlow.swift                 ~ record: RecordFlow?; commitRecord; undoLastRecord
    └── Tests/CapiaFlowTests/
        ├── RecordTests.swift             +
        ├── CardBillingTests.swift        +
        ├── RecordFlowTests.swift         +
        ├── MonthSummaryTests.swift       ~
        ├── HomeFlowTests.swift           ~
        ├── AppFlowTests.swift            ~
        └── SpaceStoreTests.swift         ~ espaço sem records; ida e volta com records
```

**Structure Decision**: Mantém os dois pacotes. Todo cálculo e estado do registro fica em
`CapiaFlow`; `ios/Capia` só desenha, mede o tempo do aviso e grava pelo `SpaceStore`. A pasta
`Record/` separa a nova tela do Início.

### Unidades de execução

1. **Base compartilhada**: `Record`, `CalendarDay`, `RecordCategory` com sugestão,
   `CardBilling`, `RecordFlow`, `records` no espaço, totais e listas do Início e
   `AppFlow` (abrir, gravar, desfazer, fechar), com testes; `NewRecordView` provisória em
   texto simples ligada ao fluxo; `CentsField` com limite. Compilar.
2. **US1**: teclado, formulário de gasto em conta, aviso "Registro salvo" (sem Desfazer),
   Início com categorias, recentes e saldo em contas. Depende de 1.
3. **US2**: receita no teclado e no formulário, receitas no Início. Depende de 2.
4. **US3**: cartão, parcelas, texto da fatura e indicador Fatura. Depende de 2.
5. **US4**: Desfazer, expiração, fechar sem salvar e aviso de falha. Depende de 2.
6. **US5**: Falar e Foto provisórios. Depende de 1.
7. **Validação integrada**: [quickstart.md](quickstart.md) no iPhone.

## Complexity Tracking

Sem violações constitucionais.

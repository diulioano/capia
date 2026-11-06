# Implementation Plan: Resumo do mês

**Branch**: `feat/003-month-summary` | **Date**: 2026-11-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-month-summary/spec.md`

A branch base `feat/003-month-summary` parte de `master`, que já integra o Get Started e a
configuração inicial validados. As branches por US estão em [tasks.md](tasks.md).

## Summary

Trocar o destino provisório de "Ver meu mês" pelo Início do quadro "Resumo do mês", com os
dados reais do espaço configurado: cabeçalho com saudação e mês, cartão do saldo com nível
de água, indicadores, capivara, seções com estado vazio, ocultar valores, botão de novo
registro e barra Início/Contas/Metas. Os cálculos do mês (saldo, sobra prevista, parcela
disponível, nível de água), a saudação, o nome do mês e o estado das abas ficam em código
puro testável no Linux. Como ainda não há registros, os totais da entrega são zero, mas o
cálculo já é testado com valores. Contas reaproveita o resumo da conclusão e o cadastro de
outra conta; novo registro e Metas são destinos provisórios.

## Technical Context

**Language/Version**: Swift 6.4.2 no Ubuntu do WSL; manifestos Swift tools 6.0, modo Swift 6.

**Primary Dependencies**: SwiftUI e Foundation do SDK; Swift Package Manager; xtool 1.24.0.
Sem bibliotecas de terceiros.

**Storage**: Sem mudança. `space.json` (`schemaVersion: 1`) da funcionalidade 002. Estado do
Início só em memória. "Adicionar outra conta" grava pelo mesmo caminho da conclusão.

**Testing**: XCTest em `ios/CapiaFlow` para totais, sinal e formato, saudação, mês, abas,
ocultar valores e navegação da raiz. Validação manual no iPhone para interface, VoiceOver,
Dynamic Type, redução de movimento e reabertura.

**Target Platform**: iPhone, iOS 17 ou posterior. Aparelho validado: "Gremio", iPhone15,2.

**Project Type**: App móvel nativo: pacote do app `ios/Capia` e pacote puro `ios/CapiaFlow`.

**Performance Goals**: Abertura do Início imperceptível; nenhuma ação espera animação.

**Constraints**: Offline; sem permissões. Centavos inteiros (`Int64`), sem `Double` nos
valores; o nível de água é a única fração, derivada de inteiros. Formato pt-BR e nomes dos
meses determinísticos, iguais no Linux e no iPhone. Alvos de toque de 44 × 44 pontos.

**Scale/Scope**: Uma tela principal, três destinos, quatro US, 18 requisitos funcionais.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Princípio | Antes da pesquisa | Após o desenho da solução |
|-----------|-------------------|---------------------------|
| I. Nativo e compilação comprovada | Conforme: cadeia xtool validada em 001 e 002 | Conforme: nenhuma dependência nova |
| II. Design e acessibilidade | Conforme: quadro "Resumo do mês" identificado | Conforme: [contrato](contracts/month-summary-ui.md) mapeia cada elemento; estados vazios registrados |
| III. Domínio financeiro | Conforme: saldo inicial não é receita; fatura distinta de gasto | Conforme: `MonthTotals` separa confirmados e previstos; fatura à parte; testes |
| IV. Protótipo antes de integrações | Conforme: sem dados de exemplo, por decisão do usuário; sem servidor | Conforme: só o espaço guardado; nada simulado como real |
| V. Estrutura e entregas verificáveis | Conforme: cálculo e estado antes da interface | Conforme: unidades separam comportamento e interface |

Sem violações. A decisão de não usar dados de exemplo veio do usuário (spec, Clarifications)
e prevalece sobre a sugestão de `docs/prototipo.md`, que fica atualizada.

## Project Structure

### Documentation (this feature)

```text
specs/003-month-summary/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
├── contracts/month-summary-ui.md
├── tasks.md
└── validation.md         # criado na implementação
```

### Source Code (repository root)

Arquivos novos (+), alterados (~) e removidos (−) previstos:

```text
ios/
├── Capia/Sources/Capia/
│   ├── AppRootView.swift                 ~ destino home; Contas pode abrir outra conta
│   ├── Design/CapiaTheme.swift           ~ cores do quadro (água, espuma, chip, barra)
│   ├── Home/
│   │   ├── HomeView.swift                + contêiner: abas, barra inferior, botão +
│   │   ├── MonthView.swift               + US1–US3: cabeçalho, saldo, indicadores, capivara, seções
│   │   ├── BalanceCardView.swift         + US1: cartão do saldo, água, ondas e vapor
│   │   ├── MonthSectionsView.swift       + US2: previstos, para onde foi, recentes
│   │   ├── AccountsTabView.swift         + US4: contas e cartões, outra conta
│   │   ├── PlaceholderTabView.swift      + US4: novo registro e metas
│   │   └── HomeCopy.swift                + textos e valores ocultos
│   ├── Setup/SpaceSummaryList.swift      + lista de contas e cartões, extraída da conclusão
│   ├── Setup/SetupDoneView.swift         ~ usa SpaceSummaryList
│   └── Setup/MonthPlaceholderView.swift  − removido
└── CapiaFlow/
    ├── Sources/CapiaFlow/
    │   ├── AppFlow.swift                 ~ month → home(HomeFlow); outra conta a partir de Contas
    │   ├── Money.swift                   ~ formato com sinal
    │   ├── MonthSummary.swift            + MonthTotals, MonthCalendar, MonthSummary
    │   └── HomeFlow.swift                + abas, aba de categorias, ocultar, destino provisório
    └── Tests/CapiaFlowTests/
        ├── AppFlowTests.swift            ~
        ├── MoneyTests.swift              ~
        ├── MonthSummaryTests.swift       +
        └── HomeFlowTests.swift           +
```

**Structure Decision**: Mantém os dois pacotes. Todo cálculo e estado do Início fica em
`CapiaFlow`; `ios/Capia` só desenha e liga eventos. Sem modelo de registros: ele chega com a
funcionalidade de registro e alimentará `MonthTotals` sem mudar a interface.

### Unidades de execução

1. **Base compartilhada**: `MonthTotals`, `MonthCalendar`, `MonthSummary`, `HomeFlow`,
   formato com sinal, destino `home` na raiz com testes; `HomeView` provisória com as três
   abas, + e destinos em texto simples; remoção do destino provisório antigo. Compilar.
2. **US1**: cabeçalho, cartão do saldo, indicadores e capivara finais. Depende de 1.
3. **US2**: seções com estados vazios e abas de "Para onde foi". Depende de 2 pela tela.
4. **US3**: ocultar valores em todos os valores do Início. Depende de 2 e 3.
5. **US4**: barra inferior e botão + finais, Contas com outra conta, Metas e novo registro.
   Depende de 1; integra com 2–4.
6. **Validação integrada**: [quickstart.md](quickstart.md) no iPhone.

## Complexity Tracking

Sem violações constitucionais.

# Modelo de dados: Resumo do mês

Tipos do pacote puro `ios/CapiaFlow`. Textos, cores e imagens pertencem a `ios/Capia`.
Sem novas entidades guardadas: o espaço continua no `space.json` da funcionalidade 002.

## Valores do mês

| Tipo | Campos | Regras |
|------|--------|--------|
| `MonthTotals` | `income`, `expenses`, `forecastIncome`, `forecastExpenses`, `bill: Cents` | Confirmados e previstos separados. `.zero` nesta entrega |
| derivado `balance: Int64` | `income − expenses` | Pode ser negativo |
| derivado `forecastBalance: Int64` | `balance + forecastIncome − forecastExpenses` | Pode ser negativo |
| derivado `availablePercent: Int?` | `round(balance × 100 ÷ income)` em 0…100 | `nil` sem receitas; arredondamento meio para cima em inteiros |
| derivado `waterLevel: Double` | `0,18 + availablePercent × 0,0062` | `0,18` sem receitas ou sem sobra; máximo `0,80` |

O saldo inicial das contas nunca entra em `MonthTotals`. A fatura não entra no saldo.

## Calendário

| Tipo | Entrada | Saída |
|------|---------|-------|
| `MonthCalendar` | `date: Date`, `timeZone: TimeZone` | `greeting`: `.morning` 5–11, `.afternoon` 12–17, `.evening` 18–4; `monthName`: "Janeiro"…"Dezembro" |

## Resumo exibido

| Tipo | Campos | Regras |
|------|--------|--------|
| `MonthSummary` | `firstName`, `hasCard`, `totals`, `calendar` | `firstName` é a primeira palavra do nome do perfil; `hasCard` quando há cartão no espaço |

## Estado do Início (somente memória)

| Tipo | Campos | Valor inicial |
|------|--------|---------------|
| `HomeTab` | `month`, `accounts`, `goals` | `month` |
| `CategoryTab` | `expenses`, `income` | `expenses` |
| `HomeFlow` | `tab`, `categoryTab`, `valuesHidden: Bool`, `showingNewRecord: Bool` | `month`, `expenses`, `false`, `false` |

| Ação | Efeito |
|------|--------|
| `select(tab)` | muda a aba; fecha o destino de novo registro |
| `openBill` | `tab = accounts` |
| `selectCategory(tab)` | muda a aba de "Para onde foi" |
| `toggleValuesHidden` | alterna ocultar valores |
| `openNewRecord` / `closeNewRecord` | abre ou fecha o destino provisório; repetir não empilha |

## Raiz

`AppFlow.Screen.month` passa a `home`. `AppFlow` guarda um `HomeFlow` enquanto o Início
existe na sessão.

| Origem | Ação | Destino |
|--------|------|---------|
| conclusão | `viewMonth` | `home`, aba `month`, `HomeFlow` novo (valores ocultos preservados na sessão) |
| app reaberto com espaço | — | `home`, aba `month` |
| `home`, aba `accounts` | `addAnotherAccount` | `setup(.account)` em `addingAccount`; Voltar leva à conclusão |
| `home` | `send(HomeAction)` | aplica ao `HomeFlow` |

`returnFromMonth` ("Voltar ao resumo") deixa de existir. `space` do Início é o mesmo do
`SetupFlow` restaurado ou concluído na sessão.

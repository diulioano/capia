# Modelo de dados: Novo registro digitado

Tipos do pacote puro `ios/CapiaFlow`. Textos, cores e imagens pertencem a `ios/Capia`.
Decisões em [research.md](research.md).

## Guardado no espaço

`ConfiguredSpace` ganha `records: [Record]`, lido com `decodeIfPresent` (ausente = `[]`).
`schemaVersion` continua 1.

| Tipo | Campos | Regras |
|------|--------|--------|
| `Record` | `id: UUID`, `kind: RecordKind`, `amount: Cents`, `description: String`, `category: RecordCategory?`, `source: PaymentSource`, `day: CalendarDay`, `installments: Int`, `savedAt: Date` | `amount` em 1…`Record.maxAmount` (99.999.999). `description` sem espaços nas pontas, até 60 caracteres. Gasto exige `category`; receita tem `category == nil`. `installments` em 1…12 e > 1 só para gasto em cartão |
| `RecordKind` | `expense`, `income` | |
| `RecordCategory` | `market`, `restaurants`, `transport`, `home`, `leisure`, `health`, `shopping`, `other` | Ordem e nomes do quadro: Mercado, Restaurantes, Transporte, Casa, Lazer, Saúde, Compras, Outros. `suggestion(for:)` conforme research §7 |
| `PaymentSource` | `account(UUID)`, `card(UUID)` | Receita só `account`. Um id que não existe mais no espaço é ignorado nos totais (não há exclusão de contas nesta entrega) |
| `CalendarDay` | `year`, `month`, `day` | Dia do calendário gregoriano no fuso do aparelho; `Comparable`; não pode ser posterior a hoje |

Nome exibido: a descrição; sem descrição, o nome da categoria (gasto) ou "Receita".

## Fatura e parcelas (derivados, não guardados)

| Tipo | Entrada | Saída |
|------|---------|-------|
| `CardBilling` | `card: CreditCard` | `effectiveClosingDay(year:month:)`; `invoice(forPurchase:)` → `Invoice`; `openInvoice(today:)` → `Invoice` |
| `Invoice` | `cardID`, `closingYear`, `closingMonth` | `dueYear`, `dueMonth` (mês seguinte quando `dueDay < closingDay`); `adding(months:)` |
| `Installment` | `index` (1…n), `amount: Cents`, `countsIn: (year, month)`, `invoice: Invoice` | `Record.installments(card:)`: a 1ª recebe o resto da divisão; `countsIn` = mês da compra + `index − 1` |

## Resumo do mês (alterações)

| Tipo | Mudança |
|------|---------|
| `MonthSummary` | Recebe registros do espaço. `totals.income` soma salário recebido e receitas do mês; `totals.expenses` soma gastos em conta do mês e parcelas que contam no mês; `totals.bill` soma as faturas abertas |
| `MonthSummary.accountsBalance: Int64` | Substitui `accountsTotal: Cents`. Saldos iniciais + salários recebidos + receitas − gastos em conta, de qualquer data. Pode ser negativo |
| `MonthSummary.expenseBreakdown: [CategoryShare]` | Gastos do mês por categoria, do maior para o menor; empate pela ordem do quadro. `percent` arredondado (meio para cima) |
| `MonthSummary.incomeBreakdown: [IncomeShare]` | Receitas do mês agrupadas pelo nome exibido; o salário recebido como "Salário" |
| `MonthSummary.recent: [RecentItem]` | Até 5 itens: registros e salários recebidos, por dia decrescente e, no mesmo dia, por `savedAt` (ou `confirmedAt`) decrescente |
| `RecentItem` | `name`, `kind`, `amount: Cents` (total da compra), `category: RecordCategory?`, `sourceName`, `installments`, `day` |
| `MonthSummary.hasRecords: Bool` | Algum registro no espaço; muda o balão da capivara |

`ConfiguredSpace.accountsTotal` deixa de ser usado pelo Início e é removido.

## Estado do registro (somente memória)

| Tipo | Campos | Valor inicial |
|------|--------|---------------|
| `RecordMode` | `type`, `speak`, `photo` | `type` |
| `RecordPhase` | `amount`, `details` | `amount` |
| `DateChoice` | `today`, `yesterday`, `other(CalendarDay)` | `today` |
| `RecordDraft` | `kind`, `amount`, `description`, `chosenCategory: RecordCategory?`, `source: PaymentSource`, `installments`, `date: DateChoice` | gasto, zero, vazio, `nil`, primeira conta, 1, `today` |
| `RecordFlow` | `mode`, `phase`, `draft`, `sources: [PaymentSource]`, `toast: SavedToast?`, `saveFailed: Bool` | `type`, `amount`, rascunho inicial, contas e depois cartões do espaço, `nil`, `false` |
| `SavedToast` | `record: Record`, `previous: RecordDraft` | Para "Desfazer" |

Derivados: `suggestedCategory` (só quando `chosenCategory == nil`), `effectiveCategory`,
`canContinue` (valor > 0), `canSave` (valor > 0 e, para gasto, categoria efetiva),
`availableSources` (receita: só contas), `showsInstallments` (gasto em cartão).

| Ação | Efeito |
|------|--------|
| `selectMode(m)` | Muda a aba; tipo e valor preservados |
| `selectKind(k)` | Muda gasto/receita no teclado; valor preservado. Receita volta a fonte para a primeira conta e parcelas a 1 |
| `press(.digit(n))`, `press(.doubleZero)`, `press(.delete)` | Teclado como caixa; ignora o que passaria de `Record.maxAmount` |
| `continueToDetails` | Só com `canContinue`; vai para `details` |
| `back` | Volta ao teclado, preservando o valor |
| `setAmount`, `setDescription`, `chooseCategory`, `chooseSource`, `stepInstallments(±1)`, `chooseDate` | Editam o rascunho. Trocar para conta zera as parcelas para 1 |
| `makeRecord(now:timeZone:id:)` | Devolve o `Record` se `canSave`; não muda o estado |
| `didSave(record)` | Mostra o aviso, guarda o rascunho anterior, volta ao teclado zerado (tipo preservado) e limpa `saveFailed` |
| `saveDidFail` | `saveFailed = true`; rascunho intacto |
| `undo` | Restaura `previous` em `details` e remove o aviso (a raiz remove o registro) |
| `dismissToast` | Remove o aviso |

## Raiz

| Origem | Ação | Destino |
|--------|------|---------|
| `home` | `send(.openNewRecord)` | Cria `RecordFlow` com as fontes do espaço; repetir não recria |
| registro aberto | `send(RecordAction)` | Aplica ao `RecordFlow` |
| registro aberto | `commitRecord(record)` | Acrescenta ao espaço da sessão e ao `SetupFlow`; `didSave` |
| registro com aviso | `undoLastRecord()` | Remove o registro do espaço da sessão; `undo` |
| registro aberto | `send(.closeNewRecord)` | Descarta o `RecordFlow` e o aviso; volta ao mês |

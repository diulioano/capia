# Pesquisa: Resumo do mês

## 1. Dados exibidos

**Decisão**: só os dados reais do espaço guardado (esclarecimento do usuário em 2026-11-06).
**Motivo**: o Início deve mostrar o que a pessoa configurou, sem alegar registros que não
existem. **Alternativas descartadas**: registros de exemplo nas contas da pessoa; dados
fixos do quadro (Conta Aurora, Seiva). Ambas exigiriam selo de exemplo e seriam descartadas
quando o registro chegasse.

## 2. Cálculo do mês sem modelo de registros

**Decisão**: `MonthTotals` recebe receitas e gastos confirmados, previstos ainda não
confirmados e fatura, em `Cents`. Saldo e sobra são `Int64` com sinal. Nesta entrega a raiz
passa `MonthTotals.zero`. **Motivo**: a constituição exige testes para cálculos financeiros;
testar com valores agora evita refazer a tela quando o registro chegar, sem criar entidades
de registro antes da necessidade. **Alternativa descartada**: modelar `Record` já nesta
entrega (estrutura sem uso, contra o princípio IV).

Fórmulas, conforme o script do quadro:

- saldo do mês = receitas − gastos;
- sobra prevista = saldo do mês + receitas previstas − gastos previstos;
- parcela disponível = arredondamento de saldo ÷ receitas × 100, limitada a 0…100;
  sem receitas, ausente;
- nível de água = 18% + parcela × 0,62% (18% a 80%); sem receitas, 18%.

A fatura não entra no saldo do mês: os gastos no cartão já contam como gastos, e o
pagamento da fatura não é um novo gasto (`CONTEXT.md`).

## 3. Saudação e mês determinísticos

**Decisão**: `MonthCalendar` recebe `Date` e `TimeZone`, usa um `Calendar(identifier:
.gregorian)` com esse fuso e uma tabela própria de nomes de meses em português.
**Motivo**: `DateFormatter` depende do idioma e dos dados ICU, que diferem entre Linux e
iPhone; uma tabela fixa garante "Novembro" em qualquer aparelho. A raiz recalcula ao
entrar no Início e quando o app volta ao primeiro plano.

## 4. Valor com sinal

**Decisão**: `BRL.format(signed:)` usa `−` (U+2212) seguido de espaço, como os registros do
quadro ("− R$ 23,50"); zero nunca leva sinal. Valores ocultos: `R$ ••••`.

## 5. Contas provisória

**Decisão**: a aba Contas mostra a lista da conclusão (extraída em `SpaceSummaryList`) e
"Adicionar outra conta", que leva ao cadastro de conta da configuração já existente
(`SetupFlow` em `addingAccount`). Ao concluir, a raiz grava e mostra a conclusão; "Ver meu
mês" volta ao Início. **Motivo**: preserva o acesso que "Voltar ao resumo" dava na 002, sem
antecipar o quadro "Contas e cartões".

## 6. Movimento

Ondas (7 s e 12 s, lineares), vapor (5 s) e contagem do saldo (0,8 s) seguem o quadro.
Com redução de movimento: ondas paradas, sem vapor, valor final direto, sem `enter` e sem
crescimento das barras. O nível de água é estático quando não há mudança de valor.

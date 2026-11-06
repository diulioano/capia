# Pesquisa: Novo registro digitado

Decisões técnicas para [spec.md](spec.md). As decisões de produto (escopo só Digitar; compra
no cartão conta no mês da compra) estão em Clarifications da spec.

## 1. Onde guardar os registros

**Decisão**: `records: [Record]` dentro do `ConfiguredSpace`, no mesmo `space.json`, na
mesma `schemaVersion: 1`, lido com `decodeIfPresent` (ausente = sem registros). **Motivo**:
segue o padrão do salário (US5 da 003): um documento atômico, uma gravação por ação, sem
migração. Espaços antigos abrem sem registros (FR-020). **Alternativas descartadas**: arquivo
separado `records.json` (duas gravações que podem divergir); subir a versão do esquema
(o `SpaceStore` descarta versões desconhecidas, e o app voltaria à configuração).

O volume previsto para o protótipo (centenas de registros) cabe em um JSON regravado
inteiro em cada salvamento, sem atraso perceptível.

## 2. Gravar antes de confirmar

**Decisão**: `RecordFlow` produz o `Record`; a raiz monta o espaço candidato
(`ConfiguredSpace.adding(_:)`), grava pelo `SpaceStore` e só então chama
`AppFlow.commitRecord(_:)`, que atualiza o espaço da sessão, mostra o aviso e zera o teclado.
Se a gravação falhar, nada muda na sessão, o formulário fica como estava e aparece "Não deu
para salvar agora. Tente de novo." com "Tentar de novo". **Motivo**: a spec exige que um
registro não seja dado como salvo sem estar guardado (casos de borda). O "Recebi" da 003
grava depois de aplicar e ignora falhas; o registro não pode repetir isso.

"Desfazer" usa o mesmo caminho: espaço candidato sem o registro, gravação, depois
`AppFlow.undoLastRecord()`. Se essa gravação falhar, o registro continua salvo, e o aviso
de falha aparece com "Tentar de novo".

## 3. Data do registro

**Decisão**: `CalendarDay` (`year`, `month`, `day`) em vez de `Date`. "Hoje" e "Ontem" saem do
relógio e do fuso do aparelho no momento de salvar, pelo mesmo calendário gregoriano de
`MonthCalendar`. **Motivo**: um registro pertence a um dia do calendário da pessoa; guardar um
instante faria o gasto mudar de dia ou de mês ao viajar ou trocar o fuso. O momento de
gravação (`savedAt: Date`) fica à parte, para ordenar registros do mesmo dia.

## 4. Fatura e mês das parcelas

**Decisão**: `CardBilling`, código puro, recebe o cartão e o dia da compra.

- Fechamento efetivo de um mês: `min(closingDay, últimoDia(mês))`.
- A compra entra na fatura que fecha no mês da compra se `dia ≤ fechamento efetivo`; senão,
  na que fecha no mês seguinte. A parcela *k* (1…n) entra na fatura *k − 1* meses depois.
- O mês do vencimento é o mês do fechamento, ou o seguinte quando `dueDay < closingDay`
  (`CreditCard.dueIsNextMonth`). O nome da fatura é o mês do vencimento ("fatura de dezembro").
- O mês em que a parcela *k* conta nos gastos é o mês da compra + *k − 1* (decisão do usuário).
- A fatura aberta de um cartão é a que fecha no próximo fechamento efetivo a partir de hoje
  (hoje incluído). O indicador Fatura soma, de todos os cartões, as parcelas atribuídas à
  fatura aberta.

**Motivo**: regra simples e testável que reproduz o exemplo do quadro ("À vista, na fatura de
dezembro") sem fixar o ciclo real, ainda aberto em `docs/descoberta.md`.

## 5. Divisão das parcelas

**Decisão**: `base = total ÷ n` (divisão inteira de centavos); a 1ª parcela recebe
`base + total mod n`, as demais `base`. O texto "3× de R$ 200,00" usa o valor da parcela
comum (`base`). Quando há resto, o texto continua mostrando `base`, e o detalhe exato aparece
só nos totais do mês. **Motivo**: soma exata (SC-004); costume dos cartões no Brasil.

## 6. Totais do mês e dinheiro em contas

**Decisão**: `MonthSummary` passa a montar `MonthTotals` a partir de salário e registros:

- `income` = salário recebido no mês + receitas com data no mês;
- `expenses` = gastos em conta com data no mês + parcelas de cartão cujo mês é o atual;
- `bill` = soma das faturas abertas (§4);
- `forecastIncome` = salário pendente, como antes.

"Em contas hoje" vira `Int64` com sinal: saldos iniciais + salários recebidos + receitas −
gastos em conta, de qualquer data. **Motivo**: `Cents` não aceita negativo e saturaria em
zero, escondendo uma conta no vermelho. A exibição usa `BRL.format(signed:)`, já existente.
Somas de `Int64` não estouram no protótipo: o limite por registro é R$ 999.999,99.

## 7. Sugestão de categoria

**Decisão**: `RecordCategory.suggestion(for:)` dobra caixa e acentos
(`folding(options: [.caseInsensitive, .diacriticInsensitive])`), separa a descrição em
palavras e procura, na ordem do quadro, palavras que comecem por um dos prefixos: Mercado
(`mercad`, `feira`, `hortifruti`, `sacol`), Restaurantes (`caf`, `restaur`, `padaria`,
`lanche`, `almo`, `jantar`, `pizza`, `ifood`), Transporte (`uber`, `99`, `onibus`, `metr`,
`posto`, `gasolina`, `combust`), Saúde (`farm`, `medic`, `consulta`, `dentista`), Casa
(`aluguel`, `luz`, `agua`, `internet`, `condom`), Lazer (`cinema`, `show`, `stream`, `bar`,
`viagem`, `jogo`) e Compras (`loja`, `roupa`, `tenis`, `livro`). **Motivo**: o quadro usa
expressões regulares por trecho, em que "bar " exige espaço e "luz" casaria dentro de outras
palavras; o início de palavra preserva a intenção e é determinístico no Linux e no iPhone.

## 8. Estado do registro e apresentação

**Decisão**: `RecordFlow`, estado puro em `CapiaFlow`, guardado em `AppFlow.record` enquanto
o registro está aberto. Ele substitui `HomeFlow.showingNewRecord`. `HomeView` mostra
`NewRecordView` sobreposta, em tela cheia, com transição de opacidade e deslocamento de 14 pt
(`.enter` do quadro, 0,34 s), sem animação com redução de movimento. O Início por baixo fica
oculto para o VoiceOver. **Alternativa descartada**: `fullScreenCover`, cuja animação de
subida não segue o quadro nem é desligada pela redução de movimento sem contornos.

O aviso "Registro salvo" dura 4,2 s, como no quadro. O tempo corre na interface, que envia
`dismissToast`; com VoiceOver ativo, o aviso fica até a próxima ação, para dar tempo de
alcançar "Desfazer".

## 9. Teclado e campo de valor

**Decisão**: o teclado do quadro é feito com botões SwiftUI (`RecordFlow.press(_:)` com
dígito, `00` e apagar), limitado a `Record.maxAmount` (R$ 999.999,99). O valor no formulário
usa `CentsField` com um parâmetro novo de limite de algarismos (8), sem mudar o uso na
configuração (11). O valor anuncia cada mudança ao VoiceOver.

## 10. Movimento

Entradas `.enter` (0,34 s), toque `.tap`/`.key` (escala 0,94), cursor piscando (1 s, em
passos), salto do valor `.amt` (0,22 s) e aviso `.toast` (0,4 s, subindo 120%) seguem o
quadro. Com redução de movimento, nada disso anima: o cursor fica fixo e o aviso aparece
direto.

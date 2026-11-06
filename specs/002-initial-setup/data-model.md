# Modelo de dados: Configuração inicial do espaço

Tipos do pacote puro `ios/CapiaFlow`, sem SwiftUI ou UIKit. Textos de interface, cores e
imagens pertencem a `ios/Capia`. Termos financeiros seguem `CONTEXT.md`.

## Entidades guardadas

| Tipo | Campos | Regras |
|------|--------|--------|
| `Cents` | `Int64` | 0 ≤ valor ≤ 99.999.999.999. Nunca `Double` |
| `SetupGoal` | `understandSpending`, `saveForGoal`, `organizeCardBills`, `leaveSpreadsheet` | Ordem e textos da spec FR-006 |
| `AccountKind` | `checking`, `savings`, `wallet` | Rótulos: Corrente/Conta corrente, Poupança, Carteira/Dinheiro em espécie |
| `Profile` | `name: String`, `goals: Set<SetupGoal>` | Nome aparado com ≥ 2 caracteres; ≥ 1 objetivo |
| `Account` | `id: UUID`, `kind`, `name: String`, `initialBalance: Cents` | Nome aparado; `wallet` sem nome vira "Carteira"; demais exigem ≥ 2 caracteres |
| `CreditCard` | `id: UUID`, `name: String`, `closingDay: Int`, `dueDay: Int` | Dias 1…31 e diferentes; `name` é o nome da conta de referência. Não é conta |
| `ConfiguredSpace` | `schemaVersion = 1`, `profile`, `accounts: [Account]`, `cards: [CreditCard]`, `completedAt: Date` | ≥ 1 conta. Ordem de inclusão preservada |

Cartão e conta são listas separadas: o cartão não guarda saldo e não é contado como conta.
Não há vínculo de pagamento de fatura nesta entrega.

## Estado em andamento (somente memória)

| Tipo | Campos | Responsabilidade |
|------|--------|------------------|
| `SetupStep` | `name`, `goals`, `account`, `balance`, `cardQuestion`, `cardDates`, `done` | Etapa visível; posição 1…6 derivada (`done` não tem posição) |
| `SetupDraft` | `name`, `goals`, `accountKind = .checking`, `accountName = ""`, `balance = 0`, `hasCard: Bool? = nil`, `closingDay = 3`, `dueDay = 10` | Valores parciais preservados ao voltar |
| `SetupMode` | `firstRun(origin: IntroStep)`, `addingAccount` | Define o destino de Voltar nas pontas do fluxo |
| `SetupFlow` | `step`, `draft`, `mode`, `accounts`, `cards`, `restored: Bool` | Transições, validação e montagem do `ConfiguredSpace` |

Valores derivados, nunca guardados: `canContinue`, `progressPosition`, `greeting` (primeira
palavra do nome aparado), `accountDisplayName` (nome aparado; `wallet` vazio → "Carteira";
outro vazio → "sua conta"), `mood` e `space` (montado a partir de perfil e listas).

## Validação de Continuar

| Etapa | Pode continuar quando |
|-------|-----------------------|
| `name` | nome aparado com ≥ 2 caracteres |
| `goals` | ≥ 1 objetivo |
| `account` | tipo `wallet`, ou nome aparado com ≥ 2 caracteres |
| `balance` | sempre (zero aceito) |
| `cardQuestion` | `hasCard != nil` |
| `cardDates` | `closingDay != dueDay` (distância fora de 5…15 dias só avisa) |

Datas do cartão: distância = `due − closing` quando `due > closing`, senão `due + 30 − closing`
(vencimento no mês seguinte). `setClosingDay` sugere `closing + 7` (acima de 31, subtrai 30)
enquanto `dueDayChosen` é falso; `setDueDay` o torna verdadeiro; outra conta o reinicia.

## Humor da capivara (derivado)

`done` → comemora; etapa válida → feliz; etapa `name` com nome vazio → calma; demais → pensando.
Com uma letra no nome, o humor é pensando e aparece "Só mais uma letrinha.".

## Transições

Ações de navegação carregam a etapa de origem. Origem diferente da etapa atual, ação
incompatível ou Continuar com etapa inválida: nenhuma mudança.

| Origem | Ação | Destino / efeito |
|--------|------|------------------|
| `name` | Continuar | `goals` |
| `goals` | Continuar | `account` |
| `account` | Continuar | `balance` |
| `balance` | Continuar | `cardQuestion` |
| `cardQuestion` com `hasCard = false` | Continuar | Anexa conta; `done` |
| `cardQuestion` com `hasCard = true` | Continuar | `cardDates` |
| `cardDates` | Continuar | Anexa conta e cartão; `done` |
| `name` em `firstRun(origin)` | Voltar | Sai do fluxo para `introduction(origin)` |
| `goals`, `balance`, `cardQuestion`, `cardDates` | Voltar | Etapa anterior, rascunho preservado |
| `account` em `firstRun` | Voltar | `goals` |
| `account` em `addingAccount` | Voltar | `done`, sem alterar listas |
| `done`, não restaurado, `hasCard = true` | Voltar | Remove o último par anexado; `cardDates` |
| `done`, não restaurado, `hasCard = false` | Voltar | Remove a última conta anexada; `cardQuestion` |
| `done` restaurado ou após cancelar outra conta | Voltar | Indisponível (não há rascunho) |
| `done` | Adicionar outra conta | Modo `addingAccount`; limpa conta e cartão do rascunho; `account` |
| `done` | Ver meu mês | Sai do fluxo para o destino provisório do mês |

Anexar ao chegar a `done` e remover ao voltar garante que Voltar e Continuar repetidos
não dupliquem contas nem cartões. Nome e objetivos não são revisitados em `addingAccount`.

## Persistência

`SpaceStore(directory: URL)` com `load() -> ConfiguredSpace?` e `save(_:) throws`.

- Arquivo `space.json`, JSON com datas ISO 8601 e chaves ordenadas, gravação atômica.
- `load` devolve `nil` para arquivo ausente, ilegível ou `schemaVersion` desconhecido, sem apagar.
- A raiz salva ao entrar em `done` e ao repetir a conclusão após "Adicionar outra conta".
- Configuração interrompida antes de `done` nunca é gravada.
- Com espaço carregado, `SetupFlow(restoring:)` começa em `done`, `restored = true`,
  perfil e listas preenchidos; "Adicionar outra conta" funciona igual.

## Telas do app (raiz)

`AppFlow` (pacote puro, testado) mantém um único destino: `getStarted(GetStartedFlow)`, `setup(SetupFlow)` ou
`month`. Abertura: espaço gravado → `month`; caso contrário → `getStarted` em `welcome`.
`month` → "Voltar ao resumo" → `setup` em `done` com o espaço atual. Ao entrar em `done`,
`AppFlow` devolve o espaço a gravar; `AppRootView` só chama o `SpaceStore`.

## Testes planejados

- `MoneyTests`: formatação (0, 5, 100, 123456, limite), atalhos, saturação, entrada por algarismos.
- `SetupFlowTests`: percurso com e sem cartão, cada validação, Voltar de todas as etapas
  preservando rascunho, origem antiga ignorada, Voltar de `done` sem duplicar, "Adicionar
  outra conta" acumulando e cancelando, Carteira sem nome, restauração sem Voltar.
- `SpaceStoreTests`: ida e volta igual, ausência, arquivo corrompido, versão desconhecida,
  diretório criado quando falta.
- `GetStartedFlowTests`: Pular de cada etapa e Configurar meu espaço levam a `setup(origin:)`.

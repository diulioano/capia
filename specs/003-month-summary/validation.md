# Validação: Resumo do mês

Registro das verificações da funcionalidade 003. Cada item consta como passou, falhou ou
pendente, com motivo. Nada é marcado como aceito sem observação no aparelho.

## Ambiente

- Branch base: `feat/003-month-summary`, a partir de `master` (`3a9fd7f`).
- Ubuntu no WSL: Swift 6.4.2, xtool 1.24.0, SDK Darwin `epoch=4`.
- Aparelho de referência: "Gremio", iPhone15,2, iOS 26.7.2.
- Autor dos commits: `Diuliano <vargasdasilveiradiuliano@gmail.com>`, configurado no
  repositório em 2026-11-06 a pedido do usuário.

## Base compartilhada (T001–T007)

Data: 2026-11-06.

| Verificação | Comando | Resultado |
|-------------|---------|-----------|
| Testes do pacote puro | `swift test --package-path ios/CapiaFlow` (Bash no WSL) | Passou: 65 testes, 0 falhas (AppFlow 10, CardDates 5, GetStarted 6, HomeFlow 5, Money 8, MonthSummary 9, SetupFlow 16, SpaceStore 6) |
| Compilação | `xtool dev build` em `ios/Capia/` | Passou. `.app` em `ios/Capia/xtool/Capia.app` |
| Instalação e percurso provisório no iPhone | `xtool dev run --usb` | Pendente: não exigido no checkpoint da base; será feito na validação da US1 |

O Início da base é provisório (texto e botões simples). Nenhuma tela provisória conta como
final.

## US1 — Ver o mês ao abrir o app

Pendente.

## US2 — Seções do mês sem registros

Pendente.

## US3 — Ocultar os valores

Pendente.

## US4 — Navegar a partir do Início

Pendente.

## Validação integrada

Pendente.

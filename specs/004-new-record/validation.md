# Validação: Novo registro digitado

Registro das verificações da funcionalidade 004. Cada item consta como passou, falhou ou
pendente, com motivo. Nada é marcado como aceito sem observação no aparelho.

## Ambiente

- Branch base: `feat/004-new-record`, a partir de `master` (`1d239e5`).
- Ubuntu no WSL: Swift 6.4.2, xtool 1.24.0.
- Aparelho de referência: "Gremio", iPhone15,2.
- Autor dos commits: `Diuliano <vargasdasilveiradiuliano@gmail.com>`.

## Base compartilhada (T001–T010)

Data: 2026-11-06.

| Verificação | Comando | Resultado |
|-------------|---------|-----------|
| Testes do pacote puro | `swift test --package-path ios/CapiaFlow` (Bash no WSL) | Passou: 132 testes, 0 falhas (AppFlow 19, CardBilling 8, CardDates 5, GetStarted 6, HomeFlow 5, Money 9, MonthSummary 22, Record 12, RecordFlow 16, SetupFlow 20, SpaceStore 10) |
| Compilação | `xtool dev build` em `ios/Capia/` | Passou, sem avisos. `.app` em `ios/Capia/xtool/Capia.app` |
| Instalação e percurso provisório no iPhone | `xtool dev run --usb` | Pendente: não exigido no checkpoint da base; será feito na validação da US1 |

O novo registro da base é provisório (texto, botões simples e controles padrão), mas já
grava antes de confirmar, desfaz e alimenta os totais do Início. Nenhuma tela provisória
conta como final.

Decisões tomadas na implementação:

- `bar`, `99` e `luz` só sugerem categoria como palavra inteira (research §7).
- `MonthCalendar` passou a guardar o dia e o fuso, usados na fatura aberta e no dia do
  salário recebido em "Registros recentes".
- Registros inválidos no `space.json` são ignorados na leitura, sem invalidar o espaço.

## US1 — Registrar um gasto digitado

Branch `feat/004-new-record-us1-expense`. T011–T015 implementadas em 2026-11-06.

| Verificação | Resultado |
|-------------|-----------|
| `xtool dev build` | Passou, sem avisos |
| `xtool dev run --usb` no "Gremio" (porta 27015) | Falhou em 2026-11-06: compilou e ficou esperando o aparelho até o limite de 200 s, sem instalar. O iPhone não estava visível ao Windows, como nas primeiras tentativas da 003 |
| T016: linhas da US1 de `quickstart.md` no iPhone, com VoiceOver, texto ampliado e redução de movimento | Pendente: depende da instalação e do aceite do usuário |

Adaptações e decisões da US1:

- Receita aparece no seletor de tipo, desabilitada, até a US2; "Pago com" mostra só contas até a US3.
- O aviso "Registro salvo" já some após 4,2 s nesta US, para não ficar preso na tela; Desfazer,
  a permanência com VoiceOver e o aviso de falha continuam na US4.
- Falar e Foto mostram por enquanto só o texto provisório; a tela final é da US5.
- A inicial dos registros usa as cores do quadro para receita, Mercado, Restaurantes e Saúde;
  Transporte, Casa, Lazer, Compras e Outros receberam pares de fundo claro e texto escuro da
  mesma família de cor, com contraste legível.
- O topo de 58 pt do quadro vira área segura + 12, como no Início.

## US2 — Registrar uma receita digitada

Pendente.

## US3 — Gastar no cartão, à vista ou parcelado

Pendente.

## US4 — Desfazer ou desistir de um registro

Pendente.

## US5 — Saber que Falar e Foto ainda vêm

Pendente.

## Validação integrada

Pendente.

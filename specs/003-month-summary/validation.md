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

Branch `feat/003-month-summary-us1-overview`. T008–T010 implementadas em 2026-11-06.

| Verificação | Resultado |
|-------------|-----------|
| `xtool dev build` | Passou |
| T011: percursos Entrada, Reabertura, Cabeçalho, Saldo, Indicadores e Capivara no iPhone, com VoiceOver, texto ampliado e redução de movimento | Passou: aceite do usuário em 2026-11-06 após uso no iPhone. VoiceOver, texto ampliado e redução de movimento não foram registrados separadamente |

Adaptações: o recuo de 58 pt do topo vira área segura + 12; o olho do cabeçalho entra na
US3, junto com o comportamento de ocultar; a contagem do saldo usa a curva do quadro
(`1 − (1 − k)³`, 0,8 s).

## US2 — Seções do mês sem registros

Branch `feat/003-month-summary-us2-sections`. T012 implementada em 2026-11-06.

| Verificação | Resultado |
|-------------|-----------|
| `xtool dev build` | Passou |
| T013: percurso Seções no iPhone, com VoiceOver e texto ampliado | Passou: aceite do usuário em 2026-11-06 após uso no iPhone. VoiceOver, texto ampliado e redução de movimento não foram registrados separadamente |

Adaptação: os botões das abas de "Para onde foi" têm 38 pt em vez de 34, para que o
controle chegue a 44 pt de alvo de toque.

## US3 — Ocultar os valores

Branch `feat/003-month-summary-us3-hide-values`. T014 implementada em 2026-11-06.

| Verificação | Resultado |
|-------------|-----------|
| `HomeFlowTests` e `AppFlowTests` (alternância, preservação ao trocar de aba e de tela) | Passou na base |
| `xtool dev build` | Passou |
| T015: percurso Ocultar no iPhone, com VoiceOver | Passou: aceite do usuário em 2026-11-06 após uso no iPhone. VoiceOver, texto ampliado e redução de movimento não foram registrados separadamente |

Adaptação: o olho usa os símbolos `eye` e `eye.slash` do sistema, no lugar dos traços do
quadro, com o mesmo botão de 44 pt, raio 14 e fundo areia.

## US4 — Navegar a partir do Início

Branch `feat/003-month-summary-us4-navigation`. T016–T018 implementadas em 2026-11-06.

| Verificação | Resultado |
|-------------|-----------|
| `swift test --package-path ios/CapiaFlow` | Passou: 65 testes, 0 falhas |
| `xtool dev build` | Passou |
| `xtool dev run --usb` no "Gremio" (porta 27015), revisão `b38a6c5` com US1–US4 | Passou em 2026-11-06: instalação e verificação concluídas. Telas ainda não conferidas |
| T019: percursos Novo registro, Contas, Outra conta, Metas e Toques rápidos no iPhone | Passou: aceite do usuário em 2026-11-06 após uso no iPhone. VoiceOver, texto ampliado e redução de movimento não foram registrados separadamente |

Adaptações: a barra inferior fica na área segura (itens de 52 pt, recuo de 10 pt no topo);
o botão + fica 20 pt acima da barra, como no quadro (112 − 92), e só aparece no Início;
o destino de novo registro abre como folha sobre o Início.

## US5 — Informar o salário e ver quanto tem

Branch `feat/003-month-summary-us5-salary`. T021–T025 implementadas em 2026-11-06.

| Verificação | Resultado |
|-------------|-----------|
| `swift test --package-path ios/CapiaFlow` | Passou: 76 testes, 0 falhas (salário na configuração, previsto e recebido, um por mês, mês seguinte, outra conta, espaço antigo sem as chaves novas) |
| `xtool dev build` | Passou |
| `xtool dev run --usb` no "Gremio", revisão `d9900fa` | Passou em 2026-11-06 na 2ª tentativa (a 1ª excedeu 5 min após compilar). Telas ainda não conferidas |
| T026: cenários da US5 no iPhone | Passou em 2026-11-06, conferido pelo usuário no "Gremio" (revisão `3562e20`): cenários 1 a 8, inclusive salário zero, "Recebi", reabertura no mesmo mês e outra conta. A volta ao previsto no mês seguinte (cenário 6) está coberta por `MonthSummaryTests`, sem mudar a data do aparelho |

Complementos ao design: etapa 5 de 7 da configuração; "Em contas hoje" no cartão do saldo;
a resposta ao "Recebi" não cita metas, que ainda não existem. Pendências registradas:
"Recebi" não pode ser desfeito e uma falha ao gravar o recebimento não é avisada.

Correção em 2026-11-06: os campos de saldo inicial e de salário acumulavam os algarismos no
fim do texto em vez de reformatar, porque o `TextField` do SwiftUI não reescreve o texto em
edição. Passaram a usar `CentsField` (`UITextField`) com a regra `Cents.editing`.
`swift test` passou com 77 testes e 0 falhas; `xtool dev build` e `xtool dev run --usb` no
"Gremio" passaram; digitação conferida pelo usuário no iPhone.

## Validação integrada

Data: 2026-11-06. Branch `feat/003-month-summary`, integrada por `git merge --ff-only` da
US5 (revisão `fe2b05d`, que inclui US1–US5 e a correção dos campos de valor `3562e20`).

| Verificação | Resultado |
|-------------|-----------|
| `swift test --package-path ios/CapiaFlow` | Passou: 77 testes, 0 falhas |
| `xtool dev build` | Passou |
| `xtool dev run --usb` no "Gremio" | Passou em 2026-11-06 na 3ª tentativa. Nas duas primeiras, o iPhone não estava visível ao Windows e o xtool encerrou após compilar, sem instalar |
| Percursos funcionais do Início (`quickstart.md`) | Passou: o usuário informou que a tela do mês está funcional |
| Acessibilidade (VoiceOver, Reduzir Movimento, maior tamanho de texto) | Pendente: não conferida na integração |
| Comparação com o quadro "Resumo do mês" no tamanho base | Pendente: não conferida na integração |

T020 continua aberta até as duas conferências pendentes.

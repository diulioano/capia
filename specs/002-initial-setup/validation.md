# Validação: Configuração inicial do espaço

Registro das verificações da funcionalidade 002. Cada item consta como passou, falhou ou
pendente, com motivo. Nada é marcado como aceito sem observação no aparelho.

## Ambiente

- Branch base: `feat/002-initial-setup`, a partir de `feat/001-get-started` (`38d7cd9`).
- Ubuntu no WSL: Swift 6.4.2, xtool 1.24.0, SDK Darwin `epoch=4, darwinTools=1.1.0, oam=1.4.1`, iPhoneOS 27.3.
- Aparelho de referência do Get Started: iPhone15,2, iOS 26.7.2.
- SwiftData indisponível para o app: `~/.swiftpm/swift-sdks/darwin.artifactbundle/OpenAppleMacrosPlugins/`
  contém apenas `libFoundationModelsMacros.so`, `libPreviewsMacros.so` e `libSwiftUIMacros.so`;
  o toolchain do SDK traz `libObservationMacros.dylib`; não há `SwiftDataMacros` (research §1).

## Base compartilhada (T001–T010)

Data: 2026-11-06. Revisão de partida: `bb94c92`.

| Verificação | Comando | Resultado |
|-------------|---------|-----------|
| Recursos | `python scripts/prepare-design-assets.py` (inclui `--check`) | Passou. `CalmCapybara.png` (célula 0,0) gerado e registrado; demais hashes inalterados |
| Testes do pacote puro | `swift test --package-path ios/CapiaFlow` (Bash no WSL) | Passou: 41 testes, 0 falhas (AppFlow 7, GetStarted 6, Money 6, SetupFlow 16, SpaceStore 6) |
| Compilação | `xtool dev build` em `ios/Capia/` | Passou. `.app` em `ios/Capia/xtool/Capia.app`; `CalmCapybara.png` presente em `Capia_Capia.bundle` |
| Instalação e percurso provisório no iPhone | `xtool dev run --usb` | Pendente: não exigido no checkpoint da base; será feito na validação da US1 |

Primeira execução dos testes: 1 falha no próprio teste `SpaceStoreTests` (a amostra era
uma propriedade calculada e gerava novos identificadores a cada acesso). Corrigida a
amostra; nenhuma mudança no código de produção.

Decisão de implementação: a lógica da raiz (abertura, saída da configuração, mês e
quando gravar) ficou em `AppFlow`, no pacote puro, em vez de só em `AppRootView`, para
ser coberta por testes no Linux. `AppRootView` apenas lê e grava o `SpaceStore`.

As etapas, a conclusão e o mês são provisórios e não contam como telas finais.

## US1 — Apresentar-se ao Capia

Branch `feat/002-initial-setup-us1-profile`. Implementação de T011–T014 concluída.

| Verificação | Resultado |
|-------------|-----------|
| `xtool dev build` | Passou |
| `xtool dev run --usb` no aparelho "Gremio" (via Apple Devices, porta 27015) | Passou: instalação e verificação concluídas em 2026-11-06 |
| Percurso da US1 no iPhone (entrada, nome, objetivos, retorno) | Passou: aprovado pelo usuário em 2026-11-06 ("está ok", "está muito bom") |
| Acessibilidade e comparação com as etapas 1–2 | Aprovado no mesmo relato, sem verificações individuais detalhadas |

Observação do usuário: o app "ainda não está estilizado 100%", conforme o combinado de fazer
primeiro o esqueleto. As etapas 3–6 e a conclusão seguem provisórias até as US2–US4.

Adaptações registradas: Voltar usa o mesmo chevron do Get Started; o rótulo "Nome ou apelido"
é o nome acessível do campo; Continuar indisponível usa o estado desativado nativo.

## US2 — Primeira conta e saldo inicial

Branch `feat/002-initial-setup-us2-account`. Implementação de T016–T017 concluída.

| Verificação | Resultado |
|-------------|-----------|
| `xtool dev build` | Passou |
| `xtool dev run --usb` no aparelho "Gremio" | Passou: instalação e verificação concluídas em 2026-11-06 |
| Percurso da US2 no iPhone (tipos, nome da conta, saldo, atalhos) | Passou: aprovado pelo usuário em 2026-11-06 ("está certo") |
| Teclado, acessibilidade e comparação com as etapas 3–4 | Aprovado no mesmo relato, sem verificações individuais detalhadas |

Sugestão do usuário para uma V2, fora desta entrega: escolher bancos existentes e aplicar
o tema de cada um no botão e no cartão. Registrada em `docs/descoberta.md`.

Adaptações: ícones dos tipos desenhados a partir dos traços SVG do quadro; atalhos passam
para coluna quando não cabem na largura com texto ampliado; valor reduz até 50% para caber.

## US3 — Cartão de crédito separado

Branch `feat/002-initial-setup-us3-card`. Implementação de T019–T020 concluída.

| Verificação | Resultado |
|-------------|-----------|
| `xtool dev build` | Passou |
| `xtool dev run --usb` no aparelho "Gremio" | 1ª tentativa falhou: `connectTimeout` ao registrar o aparelho em `api.appstoreconnect.apple.com`; 2ª tentativa passou em 2026-11-06 |
| Percurso da US3 no iPhone (sem cartão, com cartão, dias iguais, voltar) | Passou: "está funcional" |
| Regra das datas (sugestão, mês seguinte, aviso fora de 5–15) | Passou: aprovado pelo usuário em 2026-11-06 ("está ok") |
| Acessibilidade e comparação com as etapas 5–6 | Aprovado nos mesmos relatos, sem verificações individuais detalhadas |

Retorno do usuário em 2026-11-06: "está funcional", com dúvida sobre a distância entre fechamento
e vencimento. Decisão: sugerir vencimento 7 dias após o fechamento, avisar sem bloquear fora de
5 a 15 dias e informar vencimento no mês seguinte. 46 testes passaram (`CardDatesTests` +5);
nova build compilada e instalada no "Gremio" e aprovada.

Adaptações: ícones de cartão e "Agora não" desenhados a partir dos traços do quadro; dias
anunciados como "Fecha no dia N" / "Vence no dia N"; tremor omitido com Reduzir Movimento.

## US4 — Conclusão, nova conta e reabertura

Pendente.

## Validação integrada

Pendente.

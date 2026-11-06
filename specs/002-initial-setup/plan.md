# Implementation Plan: Configuração inicial do espaço

**Branch**: `feat/002-initial-setup` | **Date**: 2026-11-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-initial-setup/spec.md`

O setup usa `002-initial-setup` como identificador da funcionalidade. A branch base é
`feat/002-initial-setup`, criada a partir de `feat/001-get-started` (Get Started validado,
ainda não integrado a `master`). As branches por US serão definidas em `tasks.md`.

## Summary

Substituir a entrada provisória do Get Started pelo fluxo de seis etapas do quadro
"Configuração inicial": nome, objetivos, conta, saldo inicial, pergunta do cartão e datas,
seguidas da conclusão com resumo. O estado do fluxo, as validações e o formato monetário
ficam em código puro testável no Linux. Ao chegar à conclusão, perfil, contas e cartões
são guardados em um arquivo JSON local; ao reabrir, o app vai ao destino provisório de
"Ver meu mês". A sincronização pelo iCloud fica para funcionalidade posterior.

## Technical Context

**Language/Version**: Swift 6.4.2 no Ubuntu do WSL; manifestos Swift tools 6.0, modo Swift 6.

**Primary Dependencies**: SwiftUI e Foundation do SDK; Swift Package Manager; xtool 1.24.0.
Sem SwiftData (o SDK cruzado não traz o plugin de macros `@Model`; ver research §1) e sem
bibliotecas de terceiros.

**Storage**: Um documento JSON versionado (`schemaVersion: 1`) em Application Support,
gravado de forma atômica ao chegar à conclusão. Configuração em andamento só em memória.

**Testing**: XCTest em `ios/CapiaFlow` para transições, validações, centavos, formatação
e leitura e escrita do documento em diretório temporário. Validação manual nativa para
interface, teclado, VoiceOver, Dynamic Type, redução de movimento e reabertura.

**Target Platform**: iPhone, iOS 17 ou posterior. Aparelho validado: iPhone15,2, iOS 26.7.2.

**Project Type**: App móvel nativo: pacote do app `ios/Capia` e pacote puro `ios/CapiaFlow`.

**Performance Goals**: Concluir a configuração com conta e cartão em até dois minutos
(SC-001); gravação e leitura locais imperceptíveis; nenhuma ação espera animação.

**Constraints**: Offline; sem autenticação, rede, backend ou permissões. Valores em
centavos inteiros (`Int64`), sem `Double`. Formatação pt-BR determinística, igual no Linux
e no iPhone. Controles com alvo mínimo de 44 × 44 pontos. Nenhuma credencial versionada.

**Scale/Scope**: Um fluxo de seis etapas mais conclusão e destino provisório; quatro US;
19 requisitos funcionais; dezenas de contas no máximo por sessão.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Princípio | Antes da pesquisa | Após o desenho da solução |
|-----------|-------------------|---------------------------|
| I. Nativo e compilação comprovada | Conforme: cadeia xtool já validada no Get Started | Conforme: nenhuma dependência nova; ausência do plugin SwiftData verificada no SDK |
| II. Design e acessibilidade | Conforme: quadro "Configuração inicial" identificado | Conforme: contrato mapeia cada etapa; complementos registrados no contrato e na spec |
| III. Domínio financeiro | Conforme: conta e cartão distintos; saldo inicial | Conforme: entidades separadas, centavos exatos, sem cálculo de fatura nem pagamento |
| IV. Protótipo antes de integrações | Conforme (emenda 1.1.0): dados informados pela pessoa podem ficar no aparelho | Conforme: arquivo local, sem servidor nem iCloud |
| V. Estrutura e entregas verificáveis | Conforme: estado puro antes da interface | Conforme: unidades abaixo separam comportamento, persistência e interface |

Sem violações. A gravação local deixou de ser exceção: o usuário observou que a pessoa
precisa manter seus dados, e a constituição 1.1.0 passou a permiti-la no aparelho.

## Project Structure

### Documentation (this feature)

```text
specs/002-initial-setup/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
├── contracts/initial-setup-ui.md
├── tasks.md              # gerado por $speckit-tasks
└── validation.md         # criado na implementação
```

### Source Code (repository root)

Arquivos novos (+) e alterados (~) previstos:

```text
ios/
├── Capia/Sources/Capia/
│   ├── CapiaApp.swift                    ~ raiz passa a ser AppRootView
│   ├── AppRootView.swift                 + escolhe abertura: boas-vindas ou mês provisório
│   ├── Design/CapiaImages.swift          ~ pose calma
│   ├── Design/CapiaTheme.swift           ~ cores de seleção, borda e aviso do quadro
│   ├── GetStarted/GetStartedView.swift   ~ Pular/Configurar abrem a configuração
│   ├── GetStarted/ConfigurationEntryView.swift  − removido
│   ├── Setup/
│   │   ├── SetupView.swift               + contêiner: Voltar, progresso, capivara, dica, Continuar
│   │   ├── NameStepView.swift            + US1
│   │   ├── GoalsStepView.swift           + US1
│   │   ├── AccountStepView.swift         + US2
│   │   ├── BalanceStepView.swift         + US2
│   │   ├── CardQuestionStepView.swift    + US3
│   │   ├── CardDatesStepView.swift       + US3
│   │   ├── SetupDoneView.swift           + US4
│   │   └── MonthPlaceholderView.swift    + US4
│   └── Resources/Images/CalmCapybara.png + pose calma da folha de expressões
└── CapiaFlow/
    ├── Sources/CapiaFlow/
    │   ├── GetStartedFlow.swift          ~ configurationEntry → setup(origin:)
    │   ├── Money.swift                   + centavos e formato pt-BR
    │   ├── Space.swift                   + Perfil, Conta, Cartão, Espaço configurado
    │   ├── SetupFlow.swift               + etapas, rascunho, validações e transições
    │   └── SpaceStore.swift              + leitura e gravação atômica do JSON
    └── Tests/CapiaFlowTests/
        ├── GetStartedFlowTests.swift     ~ novo destino de Pular/Configurar
        ├── MoneyTests.swift              +
        ├── SetupFlowTests.swift          +
        └── SpaceStoreTests.swift         +
scripts/prepare-design-assets.py          ~ prepara CalmCapybara.png e confere no --check
```

**Structure Decision**: Mantém os dois pacotes do Get Started. Todo comportamento
(fluxo, validação, centavos, formato e persistência com Foundation) fica em `CapiaFlow`,
testável com `swift test` no Linux. `ios/Capia` só renderiza o estado e liga os eventos.
Não há repositórios genéricos, injeção de dependências nem roteador global; a raiz recebe
um `SpaceStore` concreto apontando para Application Support.

### Unidades de execução para a futura geração de tarefas

1. **Base compartilhada**: tipos de [data-model.md](data-model.md), `SetupFlow` com todas
   as transições, `Money`, `SpaceStore` e testes; troca do destino provisório pelo contêiner
   da configuração com etapas provisórias e conclusão provisória; `AppRootView` com abertura
   condicionada ao arquivo; pose calma. Compilar. Nenhuma etapa provisória conta como final.
2. **US1**: contêiner final (Voltar, progresso, capivara com humor, balão, Continuar fixo) e
   etapas de nome e objetivos. Depende de 1.
3. **US2**: etapas de conta e saldo, teclado numérico e atalhos. Depende de 2 pelo contêiner.
4. **US3**: pergunta do cartão e datas com aviso. Depende de 2.
5. **US4**: conclusão, confete, resumo acumulado, "Adicionar outra conta", destino de
   "Ver meu mês", gravação e reabertura. Depende de 3 e 4 para o percurso completo.
6. **Validação integrada**: [quickstart.md](quickstart.md) no iPhone, inclusive reabertura,
   acessibilidade e comparação com o quadro.

## Complexity Tracking

Sem violações constitucionais. SwiftData foi descartado por indisponibilidade da macro no
SDK cruzado, e `UserDefaults` por não ser adequado a entidades do domínio (research §1).

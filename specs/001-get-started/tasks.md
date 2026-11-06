# Tasks: Get Started e identidade do Capia

**Input**: `specs/001-get-started/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/get-started-ui.md](contracts/get-started-ui.md)
e [quickstart.md](quickstart.md).

**Tests**: Cobertura de navegação pura prevista no plano e no modelo de dados; validação
visual e de interação no app nativo. Sem testes de cálculo financeiro, pois esta entrega
não implementa cálculos. Não é obrigatório adotar TDD.

**Organization**: Estrutura compartilhada primeiro; depois US1, US2 e US3. Cada US separa
comportamento, interface e verificação. Marcar uma tarefa somente após cumprir seu resultado.

## Format: `[ID] [P?] [Story] Description`

As tarefas usam `- [ ] TNNN [P opcional] [USN quando aplicável] descrição com caminho`.
`[P]` permite trabalho em arquivos diferentes após os pré-requisitos da tarefa estarem
concluídos. Não autoriza escrita simultânea no mesmo arquivo nem cria agentes automaticamente.
Todos os caminhos de código abaixo são propostos; ainda não há implementação.

## Path Conventions

- App e recursos de execução: `ios/Capia/`.
- Estado puro e testes no Linux: `ios/CapiaFlow/`.
- Referência visual imutável: `design/App de finanças onsen — protótipo iPhone.html`.
- Recursos originais: `assets/`; preparação reproduzível: `scripts/prepare-design-assets.py`.
- Evidências futuras: `specs/001-get-started/validation.md`, com seções para base, cada US e integração.

## Branches e commits por US

Pedido do usuário em 2026-11-06: usar branches por história e commits separados por US.
As branches são locais; esta etapa não inclui push, PR ou merge em `master`.

| Etapa | Branch | Recebe antes de começar | Commit de referência |
|-------|--------|------------------------|----------------------|
| Planejamento e esqueleto compartilhado | `feat/001-get-started` | Planejamento atual | `chore(bootstrap): cria esqueleto nativo do Capia` |
| US1: boas-vindas | `feat/001-get-started-us1-welcome` | Base com T001–T008 | `feat(us1): adiciona boas-vindas do Capia` |
| US2: apresentação | `feat/001-get-started-us2-introduction` | US1 validada | `feat(us2): adiciona apresentação navegável` |
| US3: identidade instalada | `feat/001-get-started-us3-app-identity` | US2 validada | `feat(us3): adiciona ícone e identidade do Capia` |
| Validação integrada | `feat/001-get-started` | US3 e seus predecessores | `chore(validation): valida Get Started no iPhone` |

As três branches de US são criadas nesta etapa no commit de planejamento comum. A criação
das referências não significa que a implementação das histórias começou. Antes de trabalhar
em cada uma, atualizar sua base com `git merge --ff-only` da branch predecessora. Isso evita
iniciar US2 ou US3 em um esqueleto desatualizado.

O trabalho é sequencial. Depois da US3, avançar a branch base por fast-forward até sua ponta
e fazer nela a validação integrada. Não fazer commits de implementação de US na branch base.
Se uma branch já tiver trabalho e o fast-forward falhar, inspecionar e integrar os commits
necessários com merge normal, preservando o histórico; não usar reset ou force-push.

É permitido mais de um commit por história, mantendo o prefixo `us1`, `us2` ou `us3` e
agrupando separadamente comportamento e visual quando isso ajudar a revisão. Cada commit
inclui o progresso correspondente em `tasks.md` e a evidência em `validation.md`. Não incluir
código de outra US para completar artificialmente um commit.

Se faltar aparelho, salvar trabalho como `wip(usN): ...`, registrar verificações pendentes
e manter a tarefa de validação aberta. Não nomear um commit parcial como história concluída.
A branch seguinte só inicia depois do checkpoint anterior; a validação parcial não é aceite.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Criar os dois pacotes mínimos, sem construir as telas finais.

- [X] T001 [P] Criar `ios/Capia/Package.swift`, `ios/Capia/xtool.yml`, `ios/Capia/Resources/Info.plist` e `ios/Capia/Sources/Capia/CapiaApp.swift` no formato library do xtool, com Swift tools 6.0, modo Swift 6, iOS 17, produto e nome Capia e dependência local `../CapiaFlow`; usar identificador inicial `com.diuli.capia`, sem credenciais, sem configurar `iconPath` antes de existir o PNG e com tela inicial provisória que compile após T002.
- [X] T002 [P] Criar `ios/CapiaFlow/Package.swift` e a estrutura `ios/CapiaFlow/Sources/CapiaFlow/GetStartedFlow.swift` para um pacote library sem SwiftUI, UIKit, fontes ou persistência, com target XCTest em `ios/CapiaFlow/Tests/CapiaFlowTests/` e compilação independente do app.
- [X] T003 [P] Iniciar `specs/001-get-started/validation.md` registrando branch, revisão, Swift 6.4.2, xtool 1.24.0, SDK Darwin efetivamente encontrados no Ubuntu, comandos Bash e resultado atual de conexão; preservar o relato do app padrão e deixar explícito que Capia ainda não foi instalado nem validado.

**Checkpoint**: Dois pacotes presentes e documentação de ambiente criada. Não há telas finais.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Provar o esqueleto e a navegação compartilhada antes das tarefas visuais.

- [X] T004 Definir `IntroStep`, `GetStartedScreen`, `GetStartedAction` e `GetStartedFlow` em `ios/CapiaFlow/Sources/CapiaFlow/GetStartedFlow.swift` conforme `data-model.md`, preservando literalmente as restrições: "A tela inicial é sempre `welcome` em uma nova execução do app.", "Não se representa etapa por inteiro livre ou por vários booleanos de tela.", "A entrada provisória exige uma `IntroStep` como origem. Não existe origem ausente." e "Progresso é derivado da etapa: registro 1, resumo 2 e metas 3. Não é outro estado mutável.".
- [X] T005 Escrever os testes de comportamento em `ios/CapiaFlow/Tests/CapiaFlowTests/GetStartedFlowTests.swift` para o percurso completo, todos os retornos, Pular de cada etapa, origem da configuração, nova instância e eventos repetidos com origem antiga; asserções observam apenas a tela resultante, sem exigir representação interna específica.
- [X] T006 Implementar as transições puras em `ios/CapiaFlow/Sources/CapiaFlow/GetStartedFlow.swift`, usando toda a tabela de `data-model.md`: "A ação carrega a tela de onde foi emitida. Se essa origem não é mais a tela atual, a ação não muda o estado.", "Ações sem sentido na tela atual não mudam o estado; não avançam além dos limites do fluxo." e "Não há pilha de telas duplicadas. Apenas um caso da enumeração está ativo."; executar `swift test --package-path ios/CapiaFlow` e registrar resultados em `specs/001-get-started/validation.md`.
- [X] T007 Criar `ios/Capia/Sources/Capia/GetStarted/GetStartedView.swift` e conectá-lo a `ios/Capia/Sources/Capia/CapiaApp.swift`, representando provisoriamente todas as telas e suas ações; cumprir "O estado de navegação pertence à raiz `GetStartedView` em `@State` e é alterado no ator principal.", sem persistência ou roteador global, permitindo percorrer o esqueleto sem telas vazias.
- [X] T008 Compilar o esqueleto em `ios/Capia/` com `xtool dev build`, registrar comando, revisão e caminho real do `.app` em `specs/001-get-started/validation.md`, confirmar que as rotas provisórias estão ligadas sem declará-las finais e fazer commit compartilhado na branch base com o progresso em `specs/001-get-started/tasks.md`.

**Checkpoint**: Testes de transição passam e o app compila. Atualizar a branch US1 por
fast-forward a partir da base antes de iniciar a próxima fase.

## Phase 3: User Story 1 - Ser recebido pelo Capia (Priority: P1)

**Goal**: Boas-vindas fiéis ao design, com carinho na capivara e início da apresentação.
**Branch**: `feat/001-get-started-us1-welcome`.
**Independent Test**: No app sem rede, ler a proposta, tocar e renovar o carinho,
acionar Começar e voltar da primeira introdução provisória. Confirmar fontes, composição,
VoiceOver, texto ampliado e redução de movimento na welcome. US2 finaliza a apresentação.

### Estrutura e recursos da US1

- [X] T009 [US1] Criar `scripts/prepare-design-assets.py` para ler o bundle original em `design/`, extrair a capivara welcome `c98bf460-1310-48cf-b12a-570d347b97de`, copiar `assets/onsen-wallpaper-1170x2532.png` para `ios/Capia/Sources/Capia/Resources/Images/` e gerar `ios/Capia/Sources/Capia/Resources/SOURCES.md` com origem e hashes; preservar HTML e licenças e implementar modo `--check` sem escrita, conferindo somente recursos exigíveis nesta US.
- [X] T010 [P] [US1] Adicionar Figtree TTF completa e Zen Maru Gothic Bold oficial com OFL em `ios/Capia/Sources/Capia/Resources/Fonts/` e implementar `ios/Capia/Sources/Capia/Design/CapiaFonts.swift` para registro Core Text por URL antes do primeiro texto e escala semântica; registrar revisão e licença em `ios/Capia/Sources/Capia/Resources/SOURCES.md` depois de T009 e declarar recursos em `ios/Capia/Package.swift`.
- [X] T011 [P] [US1] Criar `ios/Capia/Sources/Capia/Design/CapiaTheme.swift` com cores creme `#FBF4E5`, principal `#2E2A25`, apoio `#5E564D` e ação `#5C6B34`, medidas e estilos do contrato; botão base com altura mínima 58, raio 20 e alvo mínimo 44 × 44, com crescimento por texto ampliado.

### Interface e comportamento da US1

- [X] T012 [US1] Implementar `ios/Capia/Sources/Capia/GetStarted/WelcomeView.swift` a partir das boas-vindas do quadro `d017ec14-a843-4b61-ab79-5bedc20a48eb`, com textos exatos de FR-003, fundo e mascote nos enquadramentos originais, título 34 e corpo 16 na composição base, área segura e Começar ligado à primeira introdução provisória via `ios/Capia/Sources/Capia/GetStarted/GetStartedView.swift`; depende de T009–T011.
- [X] T013 [US1] Implementar em `ios/Capia/Sources/Capia/GetStarted/WelcomeView.swift` o carinho com "Que bom te ver aqui." por 1,9 segundo: "Uma tarefa anterior cancelada não pode esconder a mensagem renovada." e "Ao sair, cancelar a tarefa e remover o feedback."; manter tarefa local cancelável e Começar disponível, sem serviço de relógio ou estado persistido.
- [X] T014 [US1] Reproduzir vapor, brilho, reflexo e ondulações da welcome em `ios/Capia/Sources/Capia/GetStarted/WelcomeView.swift`, sem interceptar toques; consultar redução de movimento para cena estática, interromper movimentos fora da tela e permitir rolagem ou reorganização quando texto ampliado exceder a área disponível.
- [X] T015 [US1] Ajustar acessibilidade em `ios/Capia/Sources/Capia/GetStarted/WelcomeView.swift` e `ios/Capia/Sources/Capia/GetStarted/GetStartedView.swift`: nome "Fazer carinho na capivara", anúncio do feedback sem prender foco, foco no título ao mudar de tela, decorações ocultas ao VoiceOver e controles alcançáveis sem truncamento.
- [X] T016 [US1] Executar o teste independente da US1 no iPhone e os cenários de carinho, renovação, saída imediata, offline, texto ampliado e redução de movimento de `specs/001-get-started/quickstart.md`; comparar welcome com o HTML, registrar evidências e SC-001 em `specs/001-get-started/validation.md`, atualizar `specs/001-get-started/tasks.md` e commitar apenas a US1 na sua branch após o aceite observado.

**Checkpoint**: Boas-vindas verificadas; o destino de Começar ainda pode ser a introdução
provisória do esqueleto. Isso não atende nem marca como concluída a US2. Sem validação
no aparelho, manter T016 pendente e identificar eventual commit como parcial.

## Phase 4: User Story 2 - Conhecer a proposta e controlar a apresentação (Priority: P1)

**Goal**: Três introduções completas com avanço, retorno, progresso e destino provisório.
**Branch**: `feat/001-get-started-us2-introduction`, atualizada com a US1 antes de editar.
**Independent Test**: Começar, percorrer as três etapas, voltar de cada uma, Pular em todas
e retornar à origem; testar Configurar meu espaço. Não depende de cadastro ou ícone final.

### Recursos e ilustrações da US2

- [ ] T017 [US2] Estender `scripts/prepare-design-assets.py` para preparar as poses do componente Capivara do primeiro quadro usadas nas três introduções, guardando imagens em `ios/Capia/Sources/Capia/Resources/Images/` e correspondências em `ios/Capia/Sources/Capia/Resources/SOURCES.md`; manter o original preservado e usar a folha de expressões de `assets/` somente se corresponder à pose da referência.
- [ ] T018 [P] [US2] Implementar `ios/Capia/Sources/Capia/GetStarted/Artwork/RegistrationArtwork.swift` com painel da etapa "Registre do seu jeito", pose correspondente, etiquetas Digitar, Falar e Foto do recibo e composições do HTML; apresentar essas opções como ilustração, sem ativar captura ou solicitar permissões; depende de T017.
- [ ] T019 [P] [US2] Implementar `ios/Capia/Sources/Capia/GetStarted/Artwork/MonthlyOverviewArtwork.swift` com Novembro, Mercado 35%, Restaurantes 20%, Transporte 13%, Lazer 11% e pose correspondente, preservando proporções do quadro e indicação discreta de exemplo; valores são parciais e não devem ser alterados para somar 100%; depende de T017.
- [ ] T020 [P] [US2] Implementar `ios/Capia/Sources/Capia/GetStarted/Artwork/GoalsArtwork.swift` com "Viagem ao Japão", 68%, R$ 12.240 de R$ 18.000, preenchimento e pose correspondente conforme o quadro; exemplo ilustrativo sem cálculo de reserva ou movimentação financeira; depende de T017.

### Contêiner, navegação e acessibilidade da US2

- [ ] T021 [US2] Implementar `ios/Capia/Sources/Capia/GetStarted/IntroductionView.swift` com os três títulos e descrições exatos do HTML, painel ilustrado, Voltar, Pular e indicador derivado da etapa; usar Continuar nas duas primeiras e Configurar meu espaço na terceira, mantendo as ilustrações acessíveis como exemplos; depende de T018–T020.
- [ ] T022 [P] [US2] Implementar `ios/Capia/Sources/Capia/GetStarted/ConfigurationEntryView.swift` conforme FR-009, com "A configuração do seu espaço vem na próxima etapa do protótipo." e "Voltar à apresentação", retornando à etapa de origem; sem cadastro, autenticação ou permissão, usando tema e fontes da US1.
- [ ] T023 [US2] Substituir os estados provisórios da apresentação e configuração em `ios/Capia/Sources/Capia/GetStarted/GetStartedView.swift` pelas views finais, reutilizando `CapiaFlow` e os testes de T005–T006 sem recriar navegação na UI; verificar Pular nas três origens e Configurar meu espaço na última, inclusive eventos antigos repetidos; depende de T021–T022.
- [ ] T024 [US2] Ajustar `ios/Capia/Sources/Capia/GetStarted/IntroductionView.swift`, `ios/Capia/Sources/Capia/GetStarted/ConfigurationEntryView.swift` e os três arquivos em `ios/Capia/Sources/Capia/GetStarted/Artwork/` para VoiceOver, foco no título, anúncio único "Etapa N de 3", maior texto acessível, rolagem e área segura; com redução de movimento, mostrar gráficos finais e omitir movimentos contínuos sem bloquear ações.
- [ ] T025 [US2] Executar no iPhone o percurso completo da US2 e os retornos de `specs/001-get-started/quickstart.md`, conferir offline, toques rápidos, fidelidade dos três painéis e SC-002 a SC-005; registrar resultados e adaptações em `specs/001-get-started/validation.md`, atualizar `specs/001-get-started/tasks.md` e commitar apenas a US2 na sua branch após validação.

**Checkpoint**: Apresentação finalizada e navegável, welcome preservada, configuração
provisória com origem correta. Sem aparelho, manter T025 pendente e commit parcial.

## Phase 5: User Story 3 - Identificar e reabrir o Capia (Priority: P2)

**Goal**: Identificar o app instalado pelo nome Capia e ícone próprio, reabrindo nas boas-vindas.
**Branch**: `feat/001-get-started-us3-app-identity`, atualizada com a US2 antes de editar.
**Independent Test**: Localizar o ícone no iPhone, conferir rosto/toalha e nome Capia,
abrir, encerrar o processo e reabrir, confirmando retorno às boas-vindas.

### Ícone e identificação da US3

- [ ] T026 [US3] Preparar `ios/Capia/Resources/AppIcon.png` a partir de `assets/capybara-onsen.png`, consultando a skill imagegen se houver edição visual; produzir master PNG 1024 × 1024 opaco, fundo creme, rosto e toalha preservados e sem máscara arredondada desenhada, e registrar origem em `ios/Capia/Sources/Capia/Resources/SOURCES.md`.
- [ ] T027 [US3] Estender o modo `--check` de `scripts/prepare-design-assets.py` para conferir o ícone em `ios/Capia/Resources/AppIcon.png`, dimensões, opacidade e recursos finais das duas histórias anteriores; saída zero apenas com todos os recursos finais presentes, sem alterar arquivos nem o HTML.
- [ ] T028 [US3] Configurar `iconPath: Resources/AppIcon.png` em `ios/Capia/xtool.yml` e conferir produto Capia, nome exibido, identificador do bundle e metadados em `ios/Capia/Resources/Info.plist`; compilar e inspecionar o ícone no bundle principal, sem presumir compilação de `.xcassets` no Linux.
- [ ] T029 [US3] Conferir em `ios/Capia/Sources/Capia/CapiaApp.swift` e `ios/Capia/Sources/Capia/GetStarted/GetStartedView.swift` que nova execução inicia em welcome, sem persistir conclusão; executar os testes de nova instância de `ios/CapiaFlow/Tests/CapiaFlowTests/GetStartedFlowTests.swift` e preservar qualquer estado apenas da sessão.
- [ ] T030 [US3] Instalar e abrir o app pelo ícone no iPhone conforme `specs/001-get-started/quickstart.md`, conferir nome, rosto/toalha em tamanho normal e reabertura após encerrar; registrar SC-006 e a revisão testada em `specs/001-get-started/validation.md`, atualizar `specs/001-get-started/tasks.md` e commitar apenas a US3 na sua branch após validação.

**Checkpoint**: Ícone e identificação confirmados na instalação. Geração de IPA não
substitui T030. Avançar a branch base até a ponta da US3 antes da integração final.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Conferir o conjunto e finalizar a documentação na branch base.

- [ ] T031 Executar `python scripts/prepare-design-assets.py --check`, `swift test --package-path ios/CapiaFlow` e `xtool dev build` em `ios/Capia/` sobre a revisão integrada, inspecionar bundles de imagens/fontes/ícone e registrar resultados em `specs/001-get-started/validation.md`; qualquer correção específica de história deve ser commitada separadamente com seu prefixo US.
- [ ] T032 Executar integralmente `specs/001-get-started/quickstart.md` no app nativo integrado, cobrindo rede indisponível, VoiceOver, redução de movimento, maior texto acessível, carinho renovado, navegação, origem da configuração e reabertura; registrar cada cenário, modelo/iOS, revisão, capturas disponíveis, resultados SC-001 a SC-006 e pendências em `specs/001-get-started/validation.md`.
- [ ] T033 Atualizar `README.md`, `docs/prototipo.md` e `specs/001-get-started/quickstart.md` para os comandos e caminhos reais da implementação; conferir conformidade com `specs/001-get-started/contracts/get-started-ui.md`, marcar somente as tarefas comprovadas em `specs/001-get-started/tasks.md` e fazer commit final de integração na branch base sem merge em `master`.

**Checkpoint**: A feature só é concluída se todas as validações exigidas forem observadas.
Uma limitação do ambiente deve continuar documentada como pendente.

## Dependencies & Execution Order

### Phase Dependencies

```text
Planejamento comum
  → Base: T001–T003 (setup)
  → Base: T004–T008 (esqueleto compilável e navegação)
  → US1: T009–T016 (boas-vindas, MVP)
  → US2: T017–T025 (apresentação e entrada provisória)
  → US3: T026–T030 (ícone e reabertura)
  → Base: T031–T033 (validação integrada)
```

### User Story Dependencies

- US1 depende do esqueleto compartilhado. Pode ser demonstrada com primeira introdução provisória.
- US2 depende da welcome e do tema/fontes da US1. Seu aceite não depende do ícone final da US3.
- US3 usa o app navegável da US2 para validar a instalação completa. Preparar a arte do ícone
  seria tecnicamente independente, mas a execução em branches adotada é sequencial.
- Cada US tem teste independente do resultado que entrega, mas não uma base de código isolada.
- Não começar a história seguinte enquanto a verificação da anterior estiver pendente.

### Within Each User Story

Resolver recursos e comportamento antes da conferência visual final. Integrar acessibilidade
na própria história. Validar, atualizar progresso e commitar na branch correta. Mudanças
em `validation.md` e `tasks.md` são sequenciais, com um escritor por vez.

### Parallel Opportunities

Há nove tarefas marcadas `[P]`. São oportunidades locais, condicionadas aos pré-requisitos,
não uma instrução para executar histórias ou branches simultaneamente.

- Setup: T001, T002 e T003 escrevem em caminhos diferentes; compilar somente após os pacotes existirem.
- US1: depois de T009, T010 e T011 podem ocorrer em paralelo; T012 depende das duas.
- US2: após T017, T018, T019 e T020 são arquivos distintos. T022 pode ocorrer durante T021;
  T023 aguarda ambas. Os três painéis usam somente tema/fontes já concluídos.
- US3: T026–T030 são sequenciais, pois verificação, empacotamento e instalação usam o ícone anterior.

## Parallel Example: User Story 1

Após T009, preparar fontes/registro em T010 enquanto se define o tema em T011.
Integrar ambos antes de implementar a welcome em T012. Não editar o mesmo manifesto ou
registro de recursos em duas tarefas ao mesmo tempo.

## Parallel Example: User Story 2

Após T017, implementar T018, T019 e T020 nos três arquivos de Artwork em paralelo.
Montar o contêiner T021 depois deles; T022 escreve apenas ConfigurationEntryView e pode
acontecer junto de T021. Reunir ambos em T023.

## Parallel Example: User Story 3

Não há par de tarefas de implementação independente nesta história. Uma inspeção visual
da arte pode acompanhar T026, mas T027 e T028 aguardam o PNG final. Evitar marcar uma
falsa oportunidade de paralelismo que empacote ícone ausente ou provisório.

## Implementation Strategy

### Rastreabilidade dos requisitos

| Escopo | Requisitos principais | Tarefas de implementação e verificação |
|--------|-----------------------|---------------------------------------|
| Base compartilhada | FR-001, FR-005, FR-007, FR-009, FR-010, FR-015 | T001–T008 |
| US1 | FR-002, FR-003, FR-004, FR-005, FR-011, FR-012, FR-013 | T009–T016 |
| US2 | FR-005, FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-012, FR-013 | T017–T025 |
| US3 | FR-001, FR-014, FR-015 | T026–T030 |
| Integração | FR-001 a FR-015 e SC-001 a SC-006 | T031–T033 |

### MVP First (User Story 1 Only)

Concluir T001–T008 na base, avançar US1 a partir dela e concluir T009–T016. Demonstrar
boas-vindas no iPhone com a transição para a primeira introdução provisória. Esse MVP
não inclui o ícone final nem declara concluída a apresentação das três etapas.

### Incremental Delivery

Integrar cada predecessor por fast-forward antes de começar a próxima US. Cada checkpoint
produz um commit revisável e um resultado observável. Depois das três histórias, integrar
na base e executar o quickstart completo. Não publicar nem distribuir o app nesta etapa.

### Notes

Os percursos do esqueleto usam placeholders apenas até serem substituídos pela US dona
da tela. Dependências, arquivos e critérios estão explícitos; não criar backend, serviços
vazios, testes de internals ou novas regras financeiras para completar esta lista.

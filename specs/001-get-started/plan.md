# Implementation Plan: Get Started e identidade do Capia

**Branch**: `feat/001-get-started` | **Date**: 2026-11-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-get-started/spec.md`

O setup usa `001-get-started` como identificador da funcionalidade. A pedido do usuário,
o trabalho usa uma branch base e branches por US, conforme [tasks.md](tasks.md).

## Summary

Implementar boas-vindas, três etapas de apresentação e entrada provisória da configuração,
com ícone e identificação Capia. A interface nativa segue o primeiro quadro do HTML,
com recursos locais e estado apenas em memória. O planejamento separa estrutura e
comportamento do acabamento visual, sem declarar o fluxo pronto antes de validar ambos.

A execução começa pelo esqueleto desta funcionalidade. O teste do app padrão no iPhone,
confirmado pelo usuário, atende ao pré-requisito inicial; a compilação deste app, seus
recursos e a instalação ainda serão comprovados na implementação.

## Technical Context

**Language/Version**: Swift 6.4.2 disponível no WSL; manifestos Swift tools 6.0 e modo Swift 6.

**Primary Dependencies**: SwiftUI, Foundation e Core Text do SDK; Swift Package Manager;
xtool 1.24.0 para compilar e empacotar. Nenhuma biblioteca de UI ou serviço de terceiros.

**Storage**: Apenas estado da sessão; nenhuma base de dados ou preferências persistidas.

**Testing**: XCTest para transições em pacote independente de UI; validação manual nativa
para interação, fontes, ícone, VoiceOver, Dynamic Type e redução de movimento.

**Target Platform**: iPhone, alvo inicial iOS 17 ou posterior, arm64. A versão do aparelho
será registrada na validação do Capia; não é necessária API posterior ao iOS 17.

**Project Type**: App móvel nativo, composto por pacote do app e pacote local de navegação.

**Performance Goals**: Começar sem aguardar animações; completar apresentação em até um
minuto; mensagem da capivara por 1,9 segundo, renovada sem acumular tarefas visíveis.
Não são resultados de medição, mas critérios a verificar no aparelho.

**Constraints**: Offline em execução; sem autenticação, backend, permissões de captura ou
integrações. Recursos e fontes empacotados. Controles com área mínima de 44 × 44 pontos.
Compilação via Ubuntu no WSL; o SDK instalado é Darwin slim, epoch 4, darwinTools 1.1.0,
oam 1.4.1. Swift e xtool não estão no PATH nativo do Windows.

**Scale/Scope**: Um fluxo, cinco estados visuais principais, três histórias, 15 requisitos.
A entrada da configuração é provisória e registra a etapa de origem para voltar.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Princípio | Antes da pesquisa | Após o desenho da solução |
|-----------|-------------------|---------------------------|
| I. Nativo e compilação comprovada | Conforme: SwiftUI e xtool; teste inicial confirmado pelo usuário | Conforme: ferramentas verificadas no WSL; comandos e validação própria do Capia no quickstart |
| II. Design e acessibilidade | Conforme: primeiro quadro e assets identificados | Conforme: composição, recursos originais, fontes locais e adaptações descritos no contrato |
| III. Domínio financeiro | Conforme: apresentação ilustrativa, sem cálculos | Conforme: previsões e rascunhos preservados no texto; nenhum modelo financeiro criado |
| IV. Protótipo antes de integrações | Conforme: estado local e sem servidor | Conforme: nenhuma persistência ou interface de rede; destino provisório delimitado |
| V. Estrutura e entregas verificáveis | Conforme: esqueleto antes do acabamento | Conforme: unidades abaixo separam comportamento e visual; validação completa no aparelho |

Sem violação ou exceção de arquitetura. A ausência de aparelho listado na pesquisa é uma
condição para a futura instalação, não falha de planejamento nem invalidação do relato
do usuário. Instalação e testes visuais não estão concluídos.

## Project Structure

### Documentation (this feature)

```text
specs/001-get-started/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
├── contracts/get-started-ui.md
└── tasks.md
```

`tasks.md` registra as tarefas e a estratégia de branches e commits por história.

### Source Code (repository root)

Estrutura proposta, ainda não criada:

```text
ios/
├── Capia/
│   ├── Package.swift
│   ├── xtool.yml
│   ├── Resources/
│   │   ├── Info.plist
│   │   └── AppIcon.png
│   └── Sources/Capia/
│       ├── CapiaApp.swift
│       ├── GetStarted/
│       │   ├── GetStartedView.swift
│       │   ├── WelcomeView.swift
│       │   ├── IntroductionView.swift
│       │   ├── Artwork/
│       │   │   ├── RegistrationArtwork.swift
│       │   │   ├── MonthlyOverviewArtwork.swift
│       │   │   └── GoalsArtwork.swift
│       │   └── ConfigurationEntryView.swift
│       ├── Design/
│       │   ├── CapiaTheme.swift
│       │   └── CapiaFonts.swift
│       └── Resources/
│           ├── Images/
│           └── Fonts/
└── CapiaFlow/
    ├── Package.swift
    ├── Sources/CapiaFlow/GetStartedFlow.swift
    └── Tests/CapiaFlowTests/GetStartedFlowTests.swift
scripts/
└── prepare-design-assets.py
```

**Structure Decision**: O pacote `ios/Capia` segue o formato library do xtool, que o
empacota como app. Ele depende de `../CapiaFlow`, pacote local puro e testável no host.
A separação existe para que `swift test --package-path ios/CapiaFlow` não precise compilar
SwiftUI no Linux. Não haverá repositórios de dados, serviços vazios ou roteador global.

`prepare-design-assets.py` será uma ferramenta de preparação reproduzível para extrair
recursos originais do bundle do HTML, copiar as imagens escolhidas e conferir integridade,
dimensões e presença das licenças. Não modificará o HTML nem gerará uma versão web do app.
O ícone será preparado a partir da capivara escolhida, com a skill imagegen se for necessária
edição visual, e guardado como PNG opaco. A ferramenta apenas o validará e copiará.

### Unidades de execução para a futura geração de tarefas

1. **Estrutura**: criar pacotes, entrada do app, metadados Capia e ligação local; compilar o
   esqueleto. Registrar identificador do bundle e versões sem incluir credenciais.
2. **Comportamento**: representar telas e eventos conforme [data-model.md](data-model.md),
   verificar transições e montar a navegação com conteúdo provisório. Nenhum desses
   estados provisórios conta como tela finalizada.
3. **Recursos e interface de boas-vindas**: preparar imagens/fontes e reproduzir cena,
   composição e interação da capivara, incluindo cancelamento do feedback ao sair.
4. **Interface da apresentação**: montar contêiner comum, três ilustrações locais,
   progresso acessível e destino provisório. Reutilizar os eventos já verificados.
5. **Identidade instalada**: preparar ícone opaco e metadados de empacotamento. Confirmar
   recursos dentro do pacote, sem depender de compilação de asset catalog no Linux.
6. **Validação integrada**: compilar, instalar e executar [quickstart.md](quickstart.md),
   comparando cada estado com o design e registrando resultados e limitações reais.

Essas unidades definem dependências para tarefas futuras, sem substituir `tasks.md`.
A unidade 2 depende da 1; a 3 usa a 2; a 4 usa as duas anteriores. O ícone pode ser
preparado após a unidade 1. A validação final depende de todas.

## Complexity Tracking

Sem violações constitucionais. O segundo pacote isola somente a navegação que precisa
ser testada no host Linux; manter tudo no pacote SwiftUI faria a seleção de testes
depender do grafo de compilação do app. Não há uma camada genérica de navegação.

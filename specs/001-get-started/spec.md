# Feature Specification: Get Started e identidade do Capia

**Feature Branch**: `feat/001-get-started` (base compartilhada; branches por US em `tasks.md`)

**Feature Directory**: `specs/001-get-started`

**Created**: 2026-11-06

**Status**: Tasks generated

**Input**: User description: "Já compilei um app padrão no iPhone e está funcionando. Começar pela tela Get Started, adicionar um ícone usando a capybara-onsen ou uma imagem gerada e definir o nome." Nome escolhido pelo usuário: Capia.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ser recebido pelo Capia (Priority: P1)

Ao abrir o app, a pessoa encontra uma cena acolhedora com a capivara no onsen,
entende a proposta de organizar o dinheiro e identifica como começar sem criar conta.

**Why this priority**: É a primeira experiência do app e permite validar sua direção visual e personalidade.

**Independent Test**: Abrir o app sem conexão, ler a proposta, interagir com a capivara e localizar a ação Começar.

**Acceptance Scenarios**:

1. **Given** o app instalado, **When** a pessoa abre o Capia, **Then** vê as boas-vindas, a cena do onsen, a proposta de controle financeiro, a informação de que não precisa criar conta e a ação Começar.
2. **Given** a tela de boas-vindas, **When** a pessoa toca na capivara, **Then** aparece a mensagem "Que bom te ver aqui." e ela desaparece após uma breve exibição, sem alterar a navegação.
3. **Given** a tela de boas-vindas, **When** a pessoa aciona Começar, **Then** entra na primeira das três etapas de apresentação.
4. **Given** redução de movimento ou leitor de tela ativado, **When** a pessoa abre as boas-vindas, **Then** consegue ler a proposta, interagir com a capivara e começar sem depender de movimentos ou elementos decorativos.

---

### User Story 2 - Conhecer a proposta e controlar a apresentação (Priority: P1)

A pessoa conhece as três propostas do Capia e pode avançar, voltar ou pular a
apresentação, sem fornecer informações pessoais ou financeiras.

**Why this priority**: Completa o primeiro quadro do design e explica o valor do app antes da configuração.

**Independent Test**: Percorrer as três etapas, voltar de cada uma e usar Pular, verificando conteúdo, posição e destino.

**Acceptance Scenarios**:

1. **Given** a primeira etapa, **When** a pessoa lê a apresentação, **Then** encontra "Registre do seu jeito", com digitação, voz e foto, e a explicação de que um rascunho será conferido antes de confirmar.
2. **Given** a primeira etapa, **When** aciona Continuar, **Then** vê "Entenda para onde vai", com um resumo ilustrativo e a distinção entre previsões e valores confirmados.
3. **Given** a segunda etapa, **When** aciona Continuar, **Then** vê "Metas sem aperto", um exemplo de progresso e a proposta de sugerir reservas mensais.
4. **Given** qualquer etapa de apresentação, **When** aciona Voltar, **Then** retorna ao estado imediatamente anterior; na primeira etapa, retorna às boas-vindas.
5. **Given** qualquer etapa de apresentação, **When** aciona Pular, **Then** chega à entrada da configuração inicial.
6. **Given** a terceira etapa, **When** aciona Configurar meu espaço, **Then** chega à mesma entrada da configuração inicial utilizada por Pular.
7. **Given** qualquer etapa de apresentação, **When** ela fica visível, **Then** o indicador visual e sua descrição acessível informam a posição correta entre as três etapas.

---

### User Story 3 - Identificar e reabrir o Capia (Priority: P2)

A pessoa reconhece o Capia na tela inicial do iPhone pelo nome e por um ícone de
capivara coerente com a experiência de boas-vindas.

**Why this priority**: Permite encontrar o protótipo instalado e estabelece sua identidade desde a primeira entrega.

**Independent Test**: Localizar o Capia na tela inicial do aparelho, conferir seu ícone e abri-lo por esse ícone.

**Acceptance Scenarios**:

1. **Given** o app instalado, **When** a pessoa procura o app na tela inicial, **Then** encontra o nome Capia e o ícone baseado na capivara do onsen, em vez do ícone padrão do projeto.
2. **Given** o ícone em tamanho de uso no aparelho, **When** a pessoa o observa, **Then** reconhece o rosto e a toalha da capivara sem recortes que prejudiquem essa identificação.
3. **Given** o app encerrado, **When** a pessoa o reabre pelo ícone, **Then** acessa novamente as boas-vindas nesta etapa do protótipo.

### Edge Cases

- Em telas menores ou com texto ampliado, a pessoa continua conseguindo ler todo o conteúdo e alcançar os botões, com rolagem quando necessária.
- A área segura do aparelho não encobre o título, a capivara interativa ou as ações de navegação.
- Com redução de movimento, vapor, reflexos, ondulações e movimentos decorativos ficam estáticos ou são omitidos, sem perda de conteúdo ou acesso às ações.
- Toques repetidos na capivara renovam a mesma mensagem temporária, sem acumular balões.
- Toques rápidos nas ações não criam apresentações duplicadas nem ultrapassam a entrada da configuração.
- Sair da tela de boas-vindas encerra seu feedback temporário; ao voltar, não há balão antigo sobre a apresentação.
- A apresentação funciona sem conexão e sem solicitar acesso a câmera, microfone, fotos ou dados bancários.
- O destino da configuração ainda não implementado não pode produzir tela vazia, encerramento inesperado ou botão sem resposta.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O app DEVE usar o nome Capia na identificação instalada e em qualquer identificação do produto exibida neste fluxo. O nome não precisa ser inserido em posições onde o design não prevê uma marca.
- **FR-002**: A abertura do app DEVE apresentar as boas-vindas do primeiro quadro do protótipo de referência, preservando a cena do onsen, a capivara, a hierarquia do conteúdo e a ação Começar.
- **FR-003**: As boas-vindas DEVEM apresentar "Boas-vindas ao seu refúgio", "Seu dinheiro em águas calmas.", o texto de apoio da referência e "Não precisa criar conta".
- **FR-004**: Tocar na capivara DEVE mostrar "Que bom te ver aqui." por aproximadamente dois segundos, renovando a exibição em novos toques e mantendo Começar disponível.
- **FR-005**: Começar DEVE abrir a primeira de três etapas, nesta ordem: "Registre do seu jeito", "Entenda para onde vai" e "Metas sem aperto".
- **FR-006**: Cada etapa DEVE preservar o conteúdo e a composição correspondente do design. Os exemplos de resumo e meta DEVEM ser identificáveis como ilustrações da apresentação, sem representar informações financeiras da pessoa.
- **FR-007**: As etapas DEVEM permitir Voltar e Pular. As duas primeiras DEVEM oferecer Continuar; a terceira DEVE oferecer Configurar meu espaço.
- **FR-008**: O indicador de progresso DEVE apresentar a etapa atual entre as três, tanto visualmente quanto para leitura assistiva.
- **FR-009**: Pular e Configurar meu espaço DEVEM levar à mesma entrada da configuração inicial. Nesta entrega, essa entrada DEVE informar "A configuração do seu espaço vem na próxima etapa do protótipo." e oferecer Voltar à apresentação, retornando à etapa de origem. Cadastro e configuração reais estão fora do escopo.
- **FR-010**: O fluxo DEVE funcionar integralmente sem conexão, autenticação, permissões de captura ou envio de informações a serviços externos.
- **FR-011**: A experiência DEVE preservar a paleta acolhedora, a hierarquia tipográfica, os espaçamentos, os componentes e as interações do design, com adaptações registradas para acessibilidade e uso no iPhone.
- **FR-012**: Textos e ações DEVEM permanecer legíveis e acessíveis com ampliação de texto. Controles DEVEM ter nomes acessíveis e áreas de toque de pelo menos 44 por 44 pontos. Elementos puramente decorativos não devem interromper a leitura assistiva.
- **FR-013**: A redução de movimento DEVE preservar todos os conteúdos, feedbacks e caminhos de navegação, sem animações decorativas contínuas ou espera obrigatória para avançar.
- **FR-014**: O app DEVE ter ícone próprio baseado em `assets/capybara-onsen.png`, preservando a identidade do mascote e sua identificação na tela inicial. O ícone DEVE ter fundo opaco coerente com o design e enquadramento que preserve o rosto e a toalha.
- **FR-015**: A reabertura após encerrar o app DEVE iniciar nas boas-vindas durante esta etapa do protótipo. Retomar uma configuração concluída será tratado com o fluxo de configuração.

### Key Entities *(include if feature involves data)*

- **Estado da apresentação**: Boas-vindas, uma das três etapas ou entrada provisória da configuração; determina as ações disponíveis, a posição anunciada e o retorno à etapa anterior.
- **Feedback da capivara**: Mensagem temporária de acolhimento, vinculada somente às boas-vindas e independente do avanço da apresentação.
- **Identidade do produto**: Nome Capia e ícone baseado na capivara do onsen, utilizados para identificar o app instalado.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Uma pessoa que abre o app consegue identificar sua proposta e iniciar a apresentação em até 15 segundos, sem orientação externa.
- **SC-002**: A apresentação completa é percorrível em até um minuto, sem inserir dados, conceder permissões ou aguardar animações.
- **SC-003**: Todos os caminhos de avanço, retorno e saída descritos nos cenários de aceitação chegam ao estado previsto, sem telas vazias ou ações sem resposta, inclusive sem conexão.
- **SC-004**: Com leitor de tela e redução de movimento, a pessoa consegue concluir o mesmo percurso das três etapas e acessar a entrada da configuração.
- **SC-005**: Na comparação com o primeiro quadro do design, todos os estados preservam os conteúdos, as ações e a composição visual, com cada adaptação de acessibilidade documentada.
- **SC-006**: No iPhone de validação, o app aparece como Capia, com ícone próprio reconhecível em tamanho normal, e abre as boas-vindas ao ser acionado.

## Assumptions

- O escopo de Get Started corresponde ao primeiro quadro "Get started e apresentação" de `design/App de finanças onsen — protótipo iPhone.html`, incluindo boas-vindas e três etapas. A configuração e primeira conta pertencem ao segundo quadro e serão uma próxima funcionalidade.
- O usuário escolheu Capia como nome em 2026-11-06. Disponibilidade comercial, domínio e registro de marca não foram verificados e não são resultados desta especificação.
- O recurso `assets/capybara-onsen.png` será reutilizado como base do ícone. Não é necessário gerar um novo mascote para esta entrega.
- O cenário de boas-vindas usa a direção visual existente, incluindo `assets/onsen-wallpaper-1170x2532.png`. O HTML original e seus avisos de licença serão preservados.
- Os valores da apresentação, como os percentuais de categorias e a meta "Viagem ao Japão", são exemplos ilustrativos; não há cálculo financeiro ou reconhecimento real nesta funcionalidade.
- O usuário confirmou em 2026-11-06 que já compilou um app padrão e o executou no iPhone. A validação inicial está atendida por relato do usuário. Isso não equivale a validar a compilação deste repositório nem a executar os cenários desta especificação.
- O planejamento deve registrar os comandos e as versões disponíveis para reproduzir a compilação neste projeto. A entrega não exige repetir o experimento do app padrão.
- O planejamento separará tarefas de estrutura e comportamento das tarefas de interface e ícone, conforme a constituição. O esqueleto será limitado ao necessário para este fluxo.
- O destino provisório da configuração é um complemento ao design, limitado ao estado descrito em FR-009. Será substituído quando o próximo fluxo for implementado.
- Não fazem parte desta entrega: contas, cartões, registros financeiros, metas operacionais, persistência de configuração concluída, integrações, publicação ou distribuição a convidados.

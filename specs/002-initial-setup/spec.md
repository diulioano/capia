# Feature Specification: Configuração inicial do espaço

**Feature Branch**: `feat/002-initial-setup` (base compartilhada; branches por US definidas em `tasks.md`)

**Feature Directory**: `specs/002-initial-setup`

**Created**: 2026-11-06

**Status**: Ready for planning

**Input**: User description: "Vamos começar agora com a segunda US já que finalizamos a primeira." Confirmado pelo usuário: o próximo fluxo é a configuração inicial do espaço, com nome, preferências, primeira conta e cartão. "Continue na próxima fase."

## Clarifications

### Session 2026-11-06

- Q: Ao reabrir o app após concluir a configuração, os dados permanecem? → A: Sim. Guardar no aparelho nesta entrega; sincronizar pelo iCloud em funcionalidade posterior, depois de definir a conta Apple e o armazenamento.

## User Scenarios & Testing *(mandatory)*

Esta funcionalidade substitui a entrada provisória da configuração criada no Get Started
(FR-009 de `specs/001-get-started/spec.md`). A referência é o quadro "Configuração inicial"
de `design/App de finanças onsen — protótipo iPhone.html`: seis etapas com barra de progresso,
capivara com balão de dica, ação Continuar fixa no rodapé e tela final de comemoração.

### User Story 1 - Apresentar-se ao Capia (Priority: P1)

Ao chegar à configuração, a pessoa informa como quer ser chamada e escolhe o que a trouxe ao
app. A capivara reage ao preenchimento e passa a cumprimentá-la pelo nome.

**Why this priority**: Abre o fluxo, substitui a entrada provisória e estabelece o tom pessoal
de todas as etapas seguintes.

**Independent Test**: A partir da apresentação, acionar Pular ou Configurar meu espaço, preencher
o nome, escolher objetivos e chegar à etapa da primeira conta; voltar de cada etapa.

**Acceptance Scenarios**:

1. **Given** a apresentação do Get Started, **When** a pessoa aciona Pular ou Configurar meu espaço, **Then** vê a primeira etapa, "Como podemos te chamar?", com o campo "Nome ou apelido", a dica "Oi! Vamos arrumar seu cantinho." e a barra de progresso na etapa 1 de 6.
2. **Given** a etapa do nome com o campo vazio ou com uma única letra, **When** a pessoa observa a ação Continuar, **Then** ela aparece indisponível; com uma letra, aparece "Só mais uma letrinha.".
3. **Given** um nome com pelo menos duas letras, **When** a pessoa aciona Continuar ou confirma pelo teclado, **Then** vê "{primeiro nome}, o que te trouxe aqui?" com quatro opções de seleção múltipla.
4. **Given** a etapa de objetivos sem nenhuma opção marcada, **When** a pessoa marca ou desmarca opções, **Then** cada opção indica seu estado e Continuar só fica disponível com pelo menos uma marcada.
5. **Given** a primeira etapa, **When** a pessoa aciona Voltar, **Then** retorna à etapa da apresentação de onde saiu; nas demais etapas, retorna à etapa anterior preservando o que já foi preenchido.

---

### User Story 2 - Cadastrar a primeira conta com saldo inicial (Priority: P1)

A pessoa escolhe o tipo da conta que mais usa, identifica o banco ou apelido e informa quanto
tem nela hoje, sem precisar cadastrar o histórico anterior.

**Why this priority**: A conta com saldo inicial é a base de todo acompanhamento financeiro e a
primeira entidade do domínio criada pela pessoa.

**Independent Test**: Escolher cada tipo de conta, preencher ou omitir o nome conforme o tipo,
informar o saldo por digitação e pelos atalhos e avançar à pergunta do cartão.

**Acceptance Scenarios**:

1. **Given** a etapa "Vamos cadastrar sua primeira conta", **When** a pessoa a abre, **Then** vê os tipos Corrente, Poupança e Carteira, com Corrente selecionado, o campo "Nome do banco ou apelido" e o aviso "Você pode adicionar outras contas depois.".
2. **Given** o tipo Corrente ou Poupança, **When** o nome tem menos de duas letras, **Then** Continuar fica indisponível.
3. **Given** o tipo Carteira, **When** a pessoa observa o campo, **Then** ele se chama "Apelido (opcional)" e Continuar fica disponível mesmo vazio; a conta passa a se chamar "Carteira".
4. **Given** a etapa "Quanto tem hoje em {nome da conta}?", **When** a pessoa digita algarismos, **Then** o valor é exibido em reais com centavos, preenchido da direita para a esquerda, a partir de R$ 0,00.
5. **Given** a etapa do saldo, **When** a pessoa aciona "+ R$ 500", "+ R$ 1.000" ou "+ R$ 2.500", **Then** o valor é somado ao saldo atual.
6. **Given** saldo zero, **When** a pessoa aciona Continuar, **Then** avança normalmente, conforme "Pode ser zero ou aproximado. Você ajusta quando quiser.".

---

### User Story 3 - Separar o cartão de crédito da conta (Priority: P1)

A pessoa informa se usa cartão de crédito e, se usar, escolhe os dias de fechamento e
vencimento. O cartão fica registrado separadamente da conta, mesmo sendo do mesmo banco.

**Why this priority**: Preserva a distinção entre conta e cartão de crédito, regra central do
domínio, e prepara a atribuição de compras e parcelas às faturas.

**Independent Test**: Responder "Agora não" e chegar à conclusão; voltar, responder "Sim, tenho
cartão", escolher dias, tentar dias iguais e concluir com dias diferentes.

**Acceptance Scenarios**:

1. **Given** a etapa "Você usa cartão de crédito de {nome da conta}?", **When** nenhuma opção está escolhida, **Then** Continuar fica indisponível; a dica informa que cartões ficam separados da conta, mesmo no mesmo banco.
2. **Given** "Agora não" escolhido, **When** a pessoa aciona Continuar, **Then** chega à conclusão sem passar pelas datas do cartão.
3. **Given** "Sim, tenho cartão" escolhido, **When** a pessoa aciona Continuar, **Then** vê "Datas do cartão {nome da conta}", com dias de 1 a 31 para "Fecha no dia" e "Vence no dia", pré-selecionados em 3 e 10.
4. **Given** dias diferentes, **When** a pessoa observa a etapa, **Then** vê "Compras a partir do dia {fechamento} entram na fatura seguinte. Parcelas são distribuídas automaticamente pelos próximos meses." e pode continuar.
5. **Given** fechamento e vencimento no mesmo dia, **When** a pessoa observa a etapa, **Then** vê "Fechamento e vencimento precisam ser em dias diferentes." e Continuar fica indisponível.

---

### User Story 4 - Concluir e revisar o espaço configurado (Priority: P2)

A pessoa vê a capivara comemorar, confere o que foi configurado e escolhe entre seguir para o
mês ou adicionar outra conta.

**Why this priority**: Fecha o fluxo com a comemoração prevista para o mascote e permite
confirmar que conta e cartão foram entendidos como entidades distintas.

**Independent Test**: Concluir com e sem cartão, conferir o resumo, adicionar uma segunda conta,
voltar da conclusão e acionar Ver meu mês.

**Acceptance Scenarios**:

1. **Given** as etapas concluídas, **When** a pessoa chega à conclusão, **Then** vê "Tudo pronto, {primeiro nome}!", "Seu refúgio está montado. Agora é só ir registrando, sem pressa.", a capivara comemorando e as ações "Ver meu mês" e "Adicionar outra conta".
2. **Given** a conclusão, **When** a pessoa confere o resumo, **Then** cada conta aparece com nome, tipo e saldo inicial; cada cartão aparece como "Cartão {nome}", com "Fecha dia X · vence dia Y" e o selo "Separado"; sem cartão, aparece "Sem cartão por enquanto.".
3. **Given** a conclusão, **When** a pessoa aciona "Adicionar outra conta", **Then** volta à etapa da conta com os campos da conta e do cartão limpos e, ao concluir, o resumo mostra as contas e cartões anteriores e os novos.
4. **Given** a conclusão, **When** a pessoa aciona "Ver meu mês", **Then** chega a um destino que informa que o resumo do mês vem na próxima etapa do protótipo e oferece retorno à conclusão, sem tela vazia ou ação sem resposta.
5. **Given** a conclusão, **When** a pessoa usa Voltar, **Then** retorna às datas do cartão ou, se respondeu "Agora não", à pergunta do cartão.
6. **Given** uma configuração concluída, **When** a pessoa encerra e reabre o app, **Then** chega ao destino de "Ver meu mês" e, ao voltar ao resumo, encontra as mesmas contas, saldos e cartões.
7. **Given** uma configuração interrompida antes da conclusão, **When** a pessoa encerra e reabre o app, **Then** volta às boas-vindas, sem dados parciais.

### Edge Cases

- Espaços no início e no fim do nome e do banco são ignorados na validação e na exibição; o cumprimento usa apenas a primeira palavra do nome.
- O saldo aceita somente algarismos, até o limite de R$ 999.999.999,99; caracteres não numéricos são descartados. Saldo negativo não é aceito nesta entrega.
- Toques rápidos e repetidos em Continuar ou Voltar não pulam etapas, não duplicam contas nem cartões e não ultrapassam a conclusão.
- Ações indisponíveis permanecem visíveis, anunciadas como indisponíveis à leitura assistiva, e não avançam o fluxo.
- Os dias 29, 30 e 31 podem ser escolhidos; o tratamento em meses mais curtos pertence às regras de fatura, ainda em aberto.
- Uma segunda conta com o mesmo nome de banco é aceita; contas e cartões permanecem distintos no resumo.
- Com teclado aberto, o campo em edição e a ação Continuar permanecem visíveis.
- Em telas menores ou com texto ampliado, conteúdo e ações continuam alcançáveis, com rolagem quando necessária; a lista horizontal de dias continua navegável.
- Com redução de movimento, transições, confete e animações da capivara ficam estáticos ou são omitidos, sem perda de conteúdo ou espera para avançar.
- O fluxo funciona sem conexão e não solicita acesso a câmera, microfone, fotos, contatos ou dados bancários.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Pular e Configurar meu espaço DEVEM abrir a primeira etapa da configuração, substituindo a entrada provisória do Get Started. Voltar na primeira etapa DEVE retornar à etapa da apresentação de origem.
- **FR-002**: A configuração DEVE ter, nesta ordem: nome, objetivos, tipo e nome da conta, saldo inicial, pergunta do cartão e datas do cartão, seguida da conclusão. A etapa das datas DEVE ser omitida quando a pessoa não informa cartão.
- **FR-003**: Cada etapa DEVE exibir a barra de progresso com sua posição entre seis, tanto visualmente quanto para leitura assistiva, a capivara e a dica correspondente do design.
- **FR-004**: A capivara DEVE refletir o estado da etapa: calma com o nome vazio, pensando enquanto a etapa está incompleta, feliz quando a etapa pode avançar e comemorando na conclusão. A expressão DEVE ser complementar ao texto, nunca a única forma de informar o estado.
- **FR-005**: Continuar DEVE ficar indisponível até a etapa atender às regras: nome com pelo menos duas letras; pelo menos um objetivo; nome do banco com pelo menos duas letras, exceto para Carteira; uma resposta sobre o cartão; fechamento diferente do vencimento. O saldo inicial pode ser zero.
- **FR-006**: Os objetivos DEVEM ser "Entender para onde vai meu dinheiro", "Juntar dinheiro para um objetivo", "Organizar as faturas do cartão" e "Deixar a planilha de lado", com seleção múltipla. Nesta entrega, as escolhas não alteram outros fluxos.
- **FR-007**: A conta DEVE ter tipo Conta corrente, Poupança ou Dinheiro em espécie (rotulado Carteira), nome e saldo inicial. A conta do tipo Carteira sem apelido DEVE se chamar "Carteira".
- **FR-008**: O saldo inicial DEVE ser representado em centavos exatos e exibido em reais no formato brasileiro, sem arredondamentos.
- **FR-009**: Responder "Sim, tenho cartão" DEVE criar um cartão de crédito distinto da conta, identificado pelo nome da conta e com dias de fechamento e vencimento. Pagar ou acompanhar faturas está fora desta entrega.
- **FR-010**: A conclusão DEVE resumir todas as contas e cartões configurados na sessão, distinguindo visualmente conta e cartão, e oferecer "Ver meu mês" e "Adicionar outra conta".
- **FR-011**: "Adicionar outra conta" DEVE reiniciar somente os campos de conta e cartão, preservando nome, objetivos e os itens já configurados.
- **FR-012**: "Ver meu mês" DEVE levar a um destino provisório que informa "O resumo do seu mês vem na próxima etapa do protótipo." e oferece "Voltar ao resumo", retornando à conclusão.
- **FR-013**: Voltar DEVE preservar os valores já informados nas etapas anteriores.
- **FR-014**: Ao chegar à conclusão, o perfil, as contas e os cartões DEVEM ser guardados somente no aparelho. Ao reabrir o app com uma configuração guardada, a pessoa DEVE chegar ao destino de "Ver meu mês", com acesso ao resumo da configuração; sem configuração concluída, o app abre nas boas-vindas. Configurações não concluídas não são guardadas. Sincronização pelo iCloud está fora desta entrega.
- **FR-015**: Os campos DEVEM usar teclado adequado (texto com iniciais maiúsculas para o nome; numérico para o saldo), permitir avançar pelo teclado quando a etapa for válida e não exigir autocorreção para nomes.
- **FR-016**: A interface DEVE preservar a paleta, a tipografia, os espaçamentos, os componentes e as interações do quadro de referência, com adaptações registradas para acessibilidade e uso no iPhone.
- **FR-017**: Textos e controles DEVEM permanecer legíveis e acessíveis com ampliação de texto. Controles DEVEM ter nomes acessíveis, estado selecionado anunciado e áreas de toque de pelo menos 44 por 44 pontos; elementos decorativos, como o confete, não interrompem a leitura assistiva.
- **FR-018**: A redução de movimento DEVE preservar todos os conteúdos, avisos e caminhos, sem animações decorativas contínuas, confete em movimento ou espera obrigatória.
- **FR-019**: O fluxo DEVE funcionar sem conexão, autenticação, permissões de captura ou envio de dados a serviços externos, e não pode alegar acesso a dados bancários reais.

### Key Entities *(include if feature involves data)*

- **Perfil da pessoa**: Nome ou apelido e objetivos escolhidos; usado para o cumprimento.
- **Conta**: Tipo, nome e saldo inicial em centavos. Origem ou destino de dinheiro, distinta de cartão de crédito conforme `CONTEXT.md`.
- **Cartão de crédito**: Nome derivado da conta de referência, dia de fechamento e dia de vencimento, diferentes entre si. Entidade separada da conta.
- **Configuração em andamento**: Etapa atual, valores parciais da conta e do cartão e itens já concluídos; determina a validade de Continuar, o destino de Voltar e o progresso exibido. Existe somente durante a sessão.
- **Espaço configurado**: Perfil, contas e cartões confirmados na conclusão e guardados no aparelho; determina a tela de abertura do app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Uma pessoa conclui a configuração com uma conta e um cartão em até dois minutos, sem orientação externa.
- **SC-002**: Em todas as etapas, Continuar só avança com a etapa válida, e cada impedimento é compreensível pela tela ou pela leitura assistiva.
- **SC-003**: Todos os caminhos de avanço, retorno, omissão do cartão, nova conta e saída descritos nos cenários chegam ao estado previsto, sem telas vazias ou ações sem resposta, inclusive sem conexão.
- **SC-004**: Os saldos digitados e somados pelos atalhos aparecem no resumo com o mesmo valor em centavos, sem diferença de arredondamento.
- **SC-005**: No resumo, a pessoa identifica corretamente quais itens são contas e quais são cartões de crédito.
- **SC-006**: Com leitor de tela, texto ampliado e redução de movimento, a pessoa conclui o mesmo percurso.
- **SC-007**: Na comparação com o quadro "Configuração inicial" do design, todas as etapas e a conclusão preservam conteúdos, ações e composição visual, com cada adaptação documentada.
- **SC-008**: Após encerrar e reabrir o app, 100% das contas, saldos e cartões confirmados aparecem iguais no resumo, e configurações interrompidas não deixam dados parciais.

## Assumptions

- O escopo corresponde ao quadro "Configuração inicial" de `design/App de finanças onsen — protótipo iPhone.html`. O HTML original e seus avisos de licença serão preservados.
- O design leva da primeira etapa à tela Main; no app, Voltar retorna à etapa da apresentação de origem, mantendo o comportamento de retorno validado no Get Started.
- O design mostra apenas a última conta na conclusão e descarta a anterior ao adicionar outra. Esta especificação acumula as contas e cartões da sessão, para que "Adicionar outra conta" não perca o que já foi informado.
- O resumo do mês ainda não existe. "Ver meu mês" usa um destino provisório, no mesmo padrão aprovado para a configuração no Get Started.
- Com o tipo Carteira, a pergunta do cartão usa o nome da conta, como no design. A identificação do emissor de cartões não vinculados a um banco cadastrado fica para o fluxo de contas e cartões.
- O texto sobre a fatura seguinte é orientação do design. Datas-limite, meses curtos e atribuição de parcelas continuam como questões abertas em `docs/descoberta.md` e não são calculados nesta entrega.
- Contas com saldo negativo, como cheque especial, não fazem parte desta entrega.
- As poses da capivara reutilizam as imagens já preparadas no Get Started e os recursos de `assets/`, como a capivara calma; novas poses só serão preparadas se a referência exigir.
- Decisão do usuário em 2026-11-06: guardar a configuração no aparelho nesta entrega e tratar a sincronização pelo iCloud como funcionalidade posterior. O recurso iCloud costuma exigir Apple Developer Program pago, ainda não confirmado; a escolha do armazenamento deve permitir sincronizar depois sem perder dados.
- Nesta entrega não há ação para apagar ou recomeçar a configuração; remover o app do iPhone apaga os dados guardados. Adicionar outra conta a partir do resumo guarda o novo item ao chegar novamente à conclusão.
- Os objetivos escolhidos ficam registrados no perfil, mas a personalização de outros fluxos a partir deles não faz parte desta entrega.
- Não fazem parte desta entrega: resumo do mês, registros, edição ou exclusão posterior de contas e cartões, faturas, metas, integrações, sincronização ou recuperação por iCloud e exportação.

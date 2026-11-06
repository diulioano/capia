# Feature Specification: Resumo do mês

**Feature Branch**: `feat/003-month-summary` (base compartilhada; branches por US definidas em `tasks.md`)

**Feature Directory**: `specs/003-month-summary`

**Created**: 2026-11-06

**Status**: Draft

**Input**: User description: "vamos, continuar para o resumo do mês". Próximo fluxo após a
configuração inicial: o destino de "Ver meu mês", que hoje é provisório.

## Clarifications

### Session 2026-11-06

- Q: Depois da configuração a pessoa só tem contas, saldos iniciais e cartões, sem registros. O que o resumo mostra nesta entrega? → A: Só os dados reais. Nada de registros, previstos ou categorias de exemplo; as seções sem dados mostram estados vazios no sistema visual do design.
- Q: (após aprovar US1–US4) O usuário pediu o salário mensal no cadastro, para planejar e mostrar de início quanto a pessoa tem. Como tratar? → A: Perguntar só o valor; o salário vira receita prevista em "Previstos para este mês", com "Recebi", e só conta como receita depois de confirmado. O Início também mostra o dinheiro em contas hoje, separado do saldo do mês (US5).

## User Scenarios & Testing *(mandatory)*

Esta funcionalidade substitui o destino provisório de "Ver meu mês" (FR-012 de
`specs/002-initial-setup/spec.md`). A referência é o quadro "Resumo do mês" de
`design/App de finanças onsen — protótipo iPhone.html`: cabeçalho com saudação e mês,
cartão do saldo com nível de água, três indicadores, capivara com balão, seções
"Previstos para este mês", "Para onde foi" e "Registros recentes", botão de novo registro
e barra Início, Contas e Metas. O quadro usa valores fictícios; esta entrega mostra os
dados reais do espaço configurado, que ainda não tem registros.

### User Story 1 - Ver o mês ao abrir o app (Priority: P1)

Ao concluir a configuração ou reabrir o app, a pessoa chega ao Início: vê em que mês está,
quanto sobrou até agora e quanto entrou, saiu e está na fatura, sem confundir o saldo
inicial das contas com receita.

**Why this priority**: É a tela inicial do produto e o destino de todo espaço configurado.
Substitui o destino provisório e dá sentido ao que foi configurado.

**Independent Test**: Concluir a configuração e acionar "Ver meu mês"; encerrar e reabrir
o app; conferir cabeçalho, cartão do saldo, indicadores e capivara com e sem cartão.

**Acceptance Scenarios**:

1. **Given** a conclusão da configuração, **When** a pessoa aciona "Ver meu mês", **Then** chega ao Início, com a aba Início selecionada.
2. **Given** um espaço guardado, **When** a pessoa reabre o app, **Then** abre direto no Início.
3. **Given** o Início, **When** a pessoa observa o cabeçalho, **Then** vê a saudação conforme o horário do aparelho ("Bom dia", "Boa tarde" ou "Boa noite") e o nome do mês atual, como "Novembro".
4. **Given** um espaço sem registros, **When** a pessoa observa o cartão do saldo, **Then** vê "Saldo do mês até agora" com R$ 0,00, "Sobra prevista no fim do mês: R$ 0,00" e o selo "Nenhuma receita registrada neste mês", com a água no nível mínimo.
5. **Given** contas com saldo inicial, **When** a pessoa observa o Início, **Then** nenhum valor do mês inclui o saldo inicial: receitas, gastos e saldo do mês continuam em R$ 0,00.
6. **Given** um espaço com cartão, **When** a pessoa observa os indicadores, **Then** vê Receitas, Gastos e Fatura, cada um com R$ 0,00; sem cartão, Fatura mostra "Sem cartão".
7. **Given** o Início, **When** a pessoa observa a capivara, **Then** ela aparece calma, com um balão que cumprimenta pelo primeiro nome e explica que o mês se preenche com os registros.

---

### User Story 2 - Entender as seções do mês sem registros (Priority: P1)

A pessoa percorre as seções do mês e entende o que cada uma vai mostrar, sem tela vazia nem
valores inventados.

**Why this priority**: As seções compõem a maior parte do quadro. Sem estados vazios claros,
a tela pareceria quebrada ou alegaria dados que não existem.

**Independent Test**: Rolar o Início; conferir as três seções; alternar Gastos e Receitas em
"Para onde foi".

**Acceptance Scenarios**:

1. **Given** o Início, **When** a pessoa observa "Previstos para este mês", **Then** vê o rótulo "nada a confirmar" e o texto "Nada previsto por enquanto. Receitas e contas que se repetem aparecem aqui para você confirmar.".
2. **Given** "Para onde foi", **When** a pessoa a abre, **Then** vê as abas Gastos e Receitas com Gastos selecionada, a barra de distribuição vazia e "Nenhum gasto registrado neste mês.".
3. **Given** "Para onde foi", **When** a pessoa aciona Receitas, **Then** a aba passa a selecionada e aparece "Nenhuma receita registrada neste mês."; ao voltar a Gastos, o texto de gastos retorna.
4. **Given** "Registros recentes", **When** a pessoa a observa, **Then** vê "Nenhum registro ainda. Use o botão + para registrar o primeiro.".

---

### User Story 3 - Ocultar os valores (Priority: P2)

A pessoa esconde os valores da tela com um toque, por exemplo em público, e os mostra de
novo quando quiser.

**Why this priority**: Recurso de privacidade presente no quadro; não bloqueia a leitura do
mês, por isso vem depois.

**Independent Test**: Acionar o botão do olho, conferir todos os valores ocultos e acionar
de novo.

**Acceptance Scenarios**:

1. **Given** os valores visíveis, **When** a pessoa aciona "Ocultar valores", **Then** todo valor em reais do Início aparece como "R$ ••••", o selo do cartão do saldo passa a "Valores ocultos" e o botão passa a "Mostrar valores".
2. **Given** os valores ocultos, **When** a pessoa aciona "Mostrar valores", **Then** os valores voltam a aparecer.
3. **Given** os valores ocultos, **When** a pessoa usa a leitura assistiva, **Then** os valores são anunciados como ocultos, sem revelar o montante, e o botão anuncia seu estado.

---

### User Story 4 - Navegar a partir do Início (Priority: P2)

A pessoa usa a barra inferior e o botão de novo registro. Cada destino responde, mesmo os
que ainda serão construídos, e as contas e cartões configurados continuam consultáveis.

**Why this priority**: Fecha a navegação principal do quadro e preserva o acesso às contas
que a configuração oferecia pelo resumo.

**Independent Test**: Acionar +, Contas, Fatura, Metas e Início; adicionar outra conta a
partir de Contas e voltar ao Início.

**Acceptance Scenarios**:

1. **Given** o Início, **When** a pessoa aciona "Adicionar registro", **Then** vê um destino que informa "O registro de receitas e gastos vem na próxima etapa do protótipo." e oferece "Voltar ao início".
2. **Given** a barra inferior, **When** a pessoa aciona Contas ou o indicador Fatura, **Then** vê a aba Contas selecionada, com cada conta (nome, tipo e saldo inicial) e cada cartão ("Cartão {nome}", "Fecha dia X · vence dia Y", selo "Separado"), o aviso de que a gestão completa de contas e cartões vem numa próxima etapa e a ação "Adicionar outra conta".
3. **Given** a aba Contas, **When** a pessoa aciona "Adicionar outra conta" e conclui o cadastro, **Then** chega à conclusão com todos os itens e, por "Ver meu mês", volta ao Início; os novos itens aparecem em Contas e permanecem após reabrir.
4. **Given** a barra inferior, **When** a pessoa aciona Metas, **Then** vê a aba Metas selecionada e "As metas de economia vêm numa próxima etapa do protótipo.".
5. **Given** Contas ou Metas, **When** a pessoa aciona Início, **Then** volta ao resumo do mês.

---

### User Story 5 - Informar o salário e ver quanto tem (Priority: P1)

Na configuração, a pessoa informa quanto recebe de salário por mês. No Início, ela vê
quanto tem nas contas hoje e o salário previsto, que confirma com "Recebi" quando cai.

**Why this priority**: Pedido do usuário após aprovar US1–US4: sem renda, o Início não
ajuda a planejar. O salário é a primeira recorrência prevista do produto.

**Independent Test**: Configurar com saldo R$ 1.000,00 e salário R$ 6.200,00; conferir o
Início antes e depois de "Recebi"; reabrir; adicionar outra conta.

**Acceptance Scenarios**:

1. **Given** a etapa do saldo concluída, **When** a pessoa aciona Continuar, **Then** vê "Quanto você recebe de salário por mês?", etapa 5 de 7, com o campo "Salário mensal" em reais e o texto "Ele aparece como previsto no seu mês até você confirmar que recebeu. Se sua renda varia, pode deixar zero.".
2. **Given** a etapa do salário, **When** a pessoa deixa zero e continua, **Then** segue para a pergunta do cartão, e o Início não mostra salário previsto.
3. **Given** um salário informado, **When** a pessoa chega à conclusão, **Then** o resumo mostra "Salário", "Receita prevista todo mês" e o valor.
4. **Given** um salário ainda não confirmado no mês, **When** a pessoa abre o Início, **Then** o saldo do mês e Receitas continuam em R$ 0,00, a sobra prevista mostra o salário, "Previstos para este mês" mostra "1 a confirmar" e a linha "Salário · todo mês · previsto" com "Recebi", e a capivara diz que é só tocar em Recebi quando ele cair.
5. **Given** o salário previsto, **When** a pessoa aciona "Recebi", **Then** a linha passa a "Recebido neste mês" com o selo "Recebido", Receitas e o saldo do mês passam ao valor do salário, a água sobe, o selo mostra "100% das receitas ainda com você", "Em contas hoje" soma o salário, "Para onde foi" › Receitas e "Registros recentes" mostram o salário, e a capivara responde "Entrou! Seu mês já conta com isso.".
6. **Given** o salário recebido, **When** a pessoa reabre o app no mesmo mês, **Then** encontra o salário como recebido; no mês seguinte, ele volta a aparecer como previsto, e o recebido continua em "Em contas hoje".
7. **Given** o Início, **When** a pessoa observa o cartão do saldo, **Then** vê "Em contas hoje: {soma dos saldos iniciais e dos salários recebidos}", distinto do saldo do mês.
8. **Given** "Adicionar outra conta", **When** a pessoa percorre o cadastro, **Then** a etapa do salário não aparece, e salário e recebimentos são preservados.

### Edge Cases

- A virada do mês ou do horário com o app aberto atualiza mês e saudação ao voltar ao Início ou ao reabrir; não é preciso atualizar em tempo real.
- Saudação: "Bom dia" das 5h às 11h59, "Boa tarde" das 12h às 17h59 e "Boa noite" das 18h às 4h59, no fuso do aparelho.
- Nome do mês em português, com inicial maiúscula, pelo calendário gregoriano, qualquer que seja o idioma do aparelho.
- Saldo do mês negativo, quando houver registros, é exibido com o sinal "−" antes de "R$" e a água no nível mínimo; nesta entrega o valor é sempre zero.
- O nível de água varia de 18% (sem sobra ou sem receita) a 80% (toda a receita ainda disponível), como no design.
- Com vários cartões, a Fatura soma as faturas abertas de todos; nesta entrega, R$ 0,00.
- O estado de "Ocultar valores" vale para a sessão; ao reabrir, os valores aparecem.
- Toques repetidos no botão +, nas abas e em "Adicionar outra conta" não empilham destinos nem duplicam itens.
- Com texto ampliado, os três indicadores e os valores continuam legíveis, com quebra ou rolagem; a barra inferior e o botão + não cobrem o último conteúdo.
- Com redução de movimento, sem entrada animada, ondas, vapor, contagem do valor ou crescimento de barras; todo conteúdo aparece direto.
- O Início funciona sem conexão e não solicita permissões.
- Se a gravação de uma conta adicionada falhar, vale o tratamento da conclusão da configuração (aviso e nova tentativa).
- "Recebi" vale uma vez por mês; toques repetidos não somam de novo. Não há como desfazer nesta entrega (o quadro não prevê); fica registrado como questão aberta.
- Se a gravação de "Recebi" falhar, o recebimento vale na sessão, sem aviso nesta entrega; fica registrado como pendência.
- O salário aceita os mesmos limites do saldo (até R$ 999.999.999,99, sem negativo). Somas acima do limite saturam.
- Espaços guardados antes do salário abrem normalmente, sem salário previsto.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: "Ver meu mês" e a abertura do app com espaço guardado DEVEM levar ao Início, substituindo o destino provisório da configuração.
- **FR-002**: O cabeçalho DEVE mostrar a saudação pelo horário do aparelho e o nome do mês atual, conforme os casos de borda.
- **FR-003**: O cartão do saldo DEVE mostrar "Saldo do mês até agora" (receitas confirmadas menos gastos confirmados do mês), "Sobra prevista no fim do mês" (o saldo do mês somado às receitas previstas e subtraído dos gastos previstos ainda não confirmados) e um selo com a parcela das receitas ainda disponível; sem receitas, o selo DEVE dizer "Nenhuma receita registrada neste mês".
- **FR-004**: O saldo inicial das contas NÃO DEVE ser contado como receita nem compor o saldo do mês, conforme `CONTEXT.md`.
- **FR-005**: Os indicadores DEVEM mostrar Receitas, Gastos e Fatura do mês. Fatura DEVE ser distinta de Gastos e levar a Contas; sem cartão, DEVE mostrar "Sem cartão".
- **FR-006**: Todos os valores DEVEM vir de centavos exatos e seguir o formato brasileiro, sem arredondamento. Nesta entrega não há registros; sem salário, cada valor do mês é R$ 0,00.
- **FR-007**: A capivara DEVE aparecer calma ao lado de um balão que cumprimenta pelo primeiro nome e orienta sem repreender. A expressão é complementar ao texto.
- **FR-008**: "Previstos para este mês", "Para onde foi" e "Registros recentes" DEVEM exibir os textos de estado vazio desta especificação, sem valores ou itens de exemplo.
- **FR-009**: "Para onde foi" DEVE alternar entre Gastos e Receitas, com Gastos selecionada ao abrir e a aba selecionada anunciada.
- **FR-010**: "Ocultar valores" DEVE substituir todo valor em reais do Início e do selo do saldo por formas ocultas, alternar com "Mostrar valores" e durar até o app ser encerrado.
- **FR-011**: O botão "Adicionar registro" DEVE abrir um destino provisório com "Voltar ao início".
- **FR-012**: A barra inferior DEVE oferecer Início, Contas e Metas, indicar a aba atual e manter-se visível nas três.
- **FR-013**: Contas DEVE listar as contas e os cartões do espaço, distinguindo conta e cartão como na conclusão, e oferecer "Adicionar outra conta", que reutiliza o cadastro da configuração e grava ao concluir. A edição e a exclusão continuam fora desta entrega.
- **FR-014**: Metas DEVE mostrar um destino provisório que informa que as metas vêm numa próxima etapa.
- **FR-015**: A interface DEVE preservar paleta, tipografia, espaçamentos, componentes e interações do quadro "Resumo do mês", com adaptações registradas para estados vazios, área segura e acessibilidade.
- **FR-016**: Controles DEVEM ter nomes acessíveis e áreas de toque de pelo menos 44 por 44 pontos. Ondas, vapor e barras são decorativos para a leitura assistiva. O cartão do saldo é lido como um único resumo.
- **FR-017**: A redução de movimento DEVE remover animações decorativas contínuas, entradas e contagens, sem perda de conteúdo.
- **FR-018**: O Início DEVE funcionar sem conexão, autenticação ou permissões e não pode alegar acesso a dados bancários reais.
- **FR-019**: A configuração DEVE ter a etapa do salário mensal depois do saldo inicial, com sete etapas no total; zero é aceito e não cria salário. "Adicionar outra conta" não repete a etapa.
- **FR-020**: O salário DEVE ser uma recorrência prevista: entra na sobra prevista e só passa a receita do mês, ao saldo do mês e ao dinheiro em contas depois de "Recebi", conforme `CONTEXT.md`. A confirmação guarda o valor e a data, uma por mês, no aparelho.
- **FR-021**: O cartão do saldo DEVE mostrar "Em contas hoje", a soma dos saldos iniciais e dos salários recebidos, sem incluir previstos nem cartões, com a mesma regra de ocultar valores.

### Key Entities *(include if feature involves data)*

- **Espaço configurado**: Perfil, contas e cartões guardados na configuração (`specs/002-initial-setup`); fonte única dos dados desta entrega.
- **Totais do mês**: Receitas e gastos confirmados, receitas e gastos previstos ainda não confirmados e fatura do mês, em centavos. Deles derivam o saldo do mês, a sobra prevista e o nível de água. Nesta entrega, só o salário os altera.
- **Salário mensal**: Valor informado na configuração; recorrência de receita prevista todo mês.
- **Recebimento do salário**: Mês, valor e data da confirmação por "Recebi"; guardado no espaço.
- **Estado do Início**: Aba atual (Início, Contas ou Metas), aba de "Para onde foi", valores ocultos e destino provisório aberto. Existe somente durante a sessão.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Após a configuração ou a reabertura, a pessoa chega ao Início em um toque ou diretamente, sem tela provisória.
- **SC-002**: Para qualquer espaço configurado sem salário recebido, 100% dos valores do mês aparecem em R$ 0,00, e nenhum incorpora o saldo inicial.
- **SC-003**: Uma pessoa identifica, sem orientação, que ainda não há registros e onde registrar o primeiro.
- **SC-004**: Todos os destinos da barra, do indicador Fatura e do botão + respondem e permitem voltar ao Início, sem telas vazias nem ações sem resposta, inclusive sem conexão.
- **SC-005**: Com os valores ocultos, nenhum montante em reais aparece na tela nem é anunciado pela leitura assistiva.
- **SC-006**: Com leitor de tela, texto ampliado e redução de movimento, a pessoa percorre o Início e os três destinos.
- **SC-007**: Na comparação com o quadro "Resumo do mês", cabeçalho, cartão do saldo, indicadores, capivara, seções, botão + e barra preservam composição e estilo, com cada adaptação documentada.
- **SC-008**: Contas adicionadas a partir de Contas aparecem iguais após reabrir o app.
- **SC-009**: Antes de "Recebi", nenhum valor confirmado inclui o salário; depois, receitas, saldo do mês e dinheiro em contas incluem o valor exato em centavos, e permanecem após reabrir.

## Assumptions

- O escopo corresponde ao quadro "Resumo do mês" de `design/App de finanças onsen — protótipo iPhone.html` (identificador `333f2428-5004-43ff-b703-276a4524089b`). O HTML original e seus avisos de licença serão preservados.
- Decisão do usuário em 2026-11-06: só dados reais. Registros, recorrências e categorias do quadro não são reproduzidos. A exceção, pedida depois pelo usuário, é o salário (US5), com "Recebi"; "Paguei" e as demais recorrências pertencem à funcionalidade de recorrências.
- Os textos de estado vazio, o selo sem receita e "Sem cartão" são complementos ao design, no mesmo sistema visual.
- O quadro mostra uma única fatura; a soma das faturas de vários cartões é uma premissa desta entrega. Ciclos, fechamento e atribuição de parcelas continuam em aberto em `docs/descoberta.md`.
- A mensagem da capivara no quadro ("Restaurantes estão 12% abaixo de outubro") depende de registros. Nesta entrega o balão cumprimenta e orienta.
- A aba Contas é provisória até o fluxo "Contas e cartões" do design. Reaproveita o resumo da conclusão para não perder o acesso que a funcionalidade 002 oferecia por "Voltar ao resumo".
- Não há navegação entre meses nesta entrega; o Início mostra o mês atual do aparelho.
- O estado de ocultar valores não é guardado no aparelho; guardá-lo pode ser decidido depois.
- Não fazem parte desta entrega: registros, recorrências, categorias, faturas calculadas, metas, edição ou exclusão de contas e cartões, sincronização e exportação.

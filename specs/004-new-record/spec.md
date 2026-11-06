# Feature Specification: Novo registro digitado

**Feature Branch**: `feat/004-new-record` (base compartilhada; branches por US definidas em `tasks.md`)

**Feature Directory**: `specs/004-new-record`

**Created**: 2026-11-06

**Status**: Draft

**Input**: User description: "comece a especificar o registro de gastos". Próximo fluxo após o
resumo do mês: o destino do botão "Adicionar registro", que hoje é provisório.

## Clarifications

### Session 2026-11-06

- Q: O quadro "Novo registro" tem as abas Digitar, Falar e Foto. Falar e Foto usam leituras simuladas com dados de exemplo, e o Início só mostra dados reais. O que esta funcionalidade cobre? → A: Só Digitar: gasto e receita digitados, conta ou cartão, parcelas, Desfazer e o Início com os registros. Falar e Foto aparecem como abas que avisam que vêm na próxima funcionalidade, na qual se decide como a simulação convive com os dados reais.
- Q: Uma compra no cartão entra em "Gastos" de qual mês? → A: No mês da compra. Numa compra parcelada, a 1ª parcela conta no mês da compra e cada parcela seguinte no mês seguinte. O indicador Fatura mostra a fatura aberta.

## User Scenarios & Testing *(mandatory)*

Esta funcionalidade substitui o destino provisório de "Adicionar registro" (FR-011 de
`specs/003-month-summary/spec.md`). A referência é o quadro "Novo registro" de
`design/App de finanças onsen — protótipo iPhone.html` (quadro "4–5 · Registro manual, voz,
imagem e revisão"). Ele tem: fechar, título, abas Digitar, Falar e Foto, seletor Gasto ou
Receita, valor com teclado numérico próprio e "Continuar". Depois vem o formulário "Só alguns
detalhes", com capivara, valor, descrição, categoria, "Pago com", parcelas no cartão e data,
os botões "Voltar" e "Salvar" e o aviso "Registro salvo" com "Desfazer". O quadro usa contas
fictícias (Conta Aurora, Cartão Aurora, Carteira); esta entrega usa as contas e os cartões do
espaço configurado. Os registros salvos passam a preencher o Início, cujo quadro "Resumo do
mês" define como aparecem.

### User Story 1 - Registrar um gasto digitado (Priority: P1)

A pessoa toca em +, digita quanto gastou, escolhe a categoria e a conta e salva. Ao voltar ao
Início, vê o gasto no mês.

**Why this priority**: É o resultado principal da primeira versão: registrar facilmente e
entender para onde o dinheiro vai. Sem ele, o Início não tem o que mostrar.

**Independent Test**: Com um espaço de uma conta com saldo inicial de R$ 1.000,00, registrar um
gasto de R$ 42,90, "Mercado", na conta, hoje. Voltar ao Início e conferir os indicadores,
"Em contas hoje", "Para onde foi" e "Registros recentes". Depois, reabrir o app.

**Acceptance Scenarios**:

1. **Given** o Início, **When** a pessoa aciona "Adicionar registro", **Then** vê "Novo registro" com a aba Digitar e o tipo Gasto selecionados, "Quanto você gastou?", o valor R$ 0,00 em cinza, o teclado (1–9, 00, 0 e apagar) e "Continuar" desabilitado.
2. **Given** o teclado, **When** a pessoa digita 4, 2, 9 e 0, **Then** o valor mostra R$ 42,90, como num caixa: cada dígito entra pela direita nos centavos, e "Continuar" fica habilitado. "00" acrescenta dois zeros e apagar remove o último dígito.
3. **Given** um valor maior que zero, **When** a pessoa aciona "Continuar", **Then** vê "Revisar registro" com a capivara pensativa, "Só alguns detalhes", "Escolha a categoria e pronto.", o valor editável, a descrição vazia ("Ex.: mercado, café, farmácia"), as oito categorias, "Pago com" com as contas e os cartões do espaço (a primeira conta selecionada) e a data em "Hoje".
4. **Given** o formulário, **When** a pessoa escreve uma descrição reconhecida, como "mercado do bairro", **Then** a categoria correspondente (Mercado) aparece selecionada com a marca "· sugerido". Ao escolher outra categoria, a escolha da pessoa prevalece.
5. **Given** um valor maior que zero e uma categoria, **When** a capivara aparece, **Then** fica feliz e "Salvar" fica habilitado. Sem categoria, ou com o valor zerado, "Salvar" fica desabilitado; com valor zero aparece "Informe um valor maior que zero.".
6. **Given** um gasto válido numa conta, **When** a pessoa aciona "Salvar", **Then** o registro é guardado no aparelho, o aviso "Registro salvo · R$ 42,90 · Mercado · {conta}" aparece com a capivara comemorando e "Desfazer", e a tela volta ao teclado, zerado, para outro registro.
7. **Given** o gasto salvo, **When** a pessoa fecha e volta ao Início, **Then** Gastos e o saldo do mês mudam pelo valor, "Em contas hoje" diminui, "Para onde foi" › Gastos mostra Mercado com o valor e 100%, e "Registros recentes" mostra "Mercado", "Mercado · {conta} · {dd/mm}" e "− R$ 42,90".
8. **Given** um gasto salvo, **When** a pessoa reabre o app, **Then** o gasto continua no Início.
9. **Given** o formulário, **When** a pessoa aciona "Voltar", **Then** retorna ao teclado com o valor digitado preservado. **When** aciona "Fechar e voltar ao resumo", **Then** volta ao Início sem salvar.
10. **Given** o formulário, **When** a pessoa escolhe "Ontem" ou "Outra data" e uma data no calendário, **Then** o registro é salvo com essa data. Uma data de mês anterior não altera os valores do mês atual, mas altera "Em contas hoje".

---

### User Story 2 - Registrar uma receita digitada (Priority: P1)

A pessoa registra um dinheiro que recebeu além do salário, como um freela, e o vê nas receitas
do mês.

**Why this priority**: Receitas e gastos formam o saldo do mês. Sem receitas avulsas, o saldo
do mês só conta o salário.

**Independent Test**: Registrar uma receita de R$ 1.150,00, "Freela · site", na conta. Conferir
Receitas, o saldo do mês, o selo do saldo, "Em contas hoje", "Para onde foi" › Receitas e
"Registros recentes".

**Acceptance Scenarios**:

1. **Given** o teclado, **When** a pessoa aciona Receita, **Then** o tipo passa a Receita, e a pergunta muda para "Quanto você recebeu?".
2. **Given** uma receita com valor, **When** a pessoa aciona "Continuar", **Then** o formulário mostra "Entrou em" com as contas do espaço, sem cartões, sem categorias e sem parcelas. "Salvar" fica habilitado com valor maior que zero.
3. **Given** uma receita válida, **When** a pessoa salva, **Then** o aviso mostra "Registro salvo · + R$ 1.150,00 · Freela · site · {conta}".
4. **Given** a receita salva, **When** a pessoa volta ao Início, **Then** Receitas e o saldo do mês aumentam pelo valor, o selo do saldo mostra a parcela das receitas ainda disponível, "Em contas hoje" aumenta, "Para onde foi" › Receitas mostra "Freela · site", e "Registros recentes" mostra o valor como "+ R$ 1.150,00", em verde.
5. **Given** uma receita sem descrição, **When** a pessoa salva, **Then** ela aparece como "Receita".
6. **Given** o tipo Receita, **When** a pessoa volta para Gasto antes de continuar, **Then** o valor digitado é preservado e o fluxo segue como gasto.

---

### User Story 3 - Gastar no cartão, à vista ou parcelado (Priority: P2)

A pessoa registra uma compra no cartão de crédito, escolhe em quantas vezes e vê a parcela do
mês nos gastos e na fatura, sem mexer no dinheiro das contas.

**Why this priority**: Conta e cartão separados e compras parceladas são decisões confirmadas da
v1. Depende do gasto digitado (US1).

**Independent Test**: Com um cartão que fecha no dia 3 e vence no dia 10, registrar em 5/11 uma
compra de R$ 600,00 em 3×. Conferir o texto das parcelas, Gastos, Fatura, "Em contas hoje" e
"Registros recentes". Repetir à vista.

**Acceptance Scenarios**:

1. **Given** o formulário de um gasto, **When** a pessoa escolhe um cartão em "Pago com", **Then** aparece "Parcelas" com "1×", os botões "Menos parcelas" e "Mais parcelas" e o texto "À vista, na fatura de {mês}". O mês é o do vencimento da fatura em que a compra entra.
2. **Given** o cartão escolhido, **When** a pessoa aumenta para 3×, **Then** o texto mostra "3× de R$ 200,00 · até {mês abreviado da última fatura}". As parcelas vão de 1× a 12×.
3. **Given** um cartão com parcelas acima de 1×, **When** a pessoa escolhe uma conta, **Then** "Parcelas" some, e o gasto volta a ser à vista.
4. **Given** uma compra de R$ 600,00 em 3× salva em novembro, **When** a pessoa volta ao Início, **Then** Gastos, o saldo do mês e "Para onde foi" contam R$ 200,00 em novembro, "Em contas hoje" não muda, Fatura soma as parcelas da fatura aberta, e "Registros recentes" mostra "− R$ 600,00" com "{categoria} · Cartão {nome} · 3× · {dd/mm}".
5. **Given** a mesma compra, **When** chega o mês seguinte, **Then** Gastos daquele mês contam a 2ª parcela, e o mês depois, a 3ª.
6. **Given** um valor que não se divide em centavos iguais, como R$ 100,00 em 3×, **When** a compra é salva, **Then** as parcelas somam exatamente o total, e o centavo restante fica na 1ª parcela (R$ 33,34, R$ 33,33, R$ 33,33).
7. **Given** um espaço sem cartão, **When** a pessoa registra um gasto, **Then** "Pago com" mostra só as contas, e "Parcelas" nunca aparece.

---

### User Story 4 - Desfazer ou desistir de um registro (Priority: P2)

A pessoa errou ao salvar e desfaz pelo aviso, ou desiste no meio sem deixar rastro.

**Why this priority**: Registrar rápido exige corrigir rápido. Como não há edição nem exclusão de
registros nesta entrega, "Desfazer" é a correção disponível.

**Independent Test**: Salvar um gasto e acionar "Desfazer" no aviso. Conferir o formulário
restaurado e o Início inalterado. Salvar, esperar o aviso sumir e conferir o registro no
Início.

**Acceptance Scenarios**:

1. **Given** o aviso "Registro salvo", **When** a pessoa aciona "Desfazer", **Then** o registro é removido do aparelho, o aviso some e o formulário volta com os valores que tinha antes de salvar.
2. **Given** o aviso, **When** passam cerca de 4 segundos sem ação, **Then** o aviso some, e o registro permanece.
3. **Given** um registro salvo e o aviso visível, **When** a pessoa fecha e volta ao Início, **Then** o registro aparece no Início, e o aviso não é mais oferecido.
4. **Given** valores digitados, **When** a pessoa fecha o registro, **Then** nada é salvo, e o próximo "Adicionar registro" começa do zero.

---

### User Story 5 - Saber que Falar e Foto ainda vêm (Priority: P3)

A pessoa vê as três formas de registro do design e entende que, por enquanto, só Digitar
funciona.

**Why this priority**: Preserva a composição do quadro e evita abas sem resposta. O
reconhecimento simulado pertence à próxima funcionalidade.

**Independent Test**: Acionar Falar e Foto e voltar a Digitar.

**Acceptance Scenarios**:

1. **Given** "Novo registro", **When** a pessoa aciona Falar, **Then** a aba fica selecionada e mostra a capivara calma com "Registrar falando vem na próxima etapa do protótipo. Por enquanto, use Digitar." e a ação "Digitar".
2. **Given** "Novo registro", **When** a pessoa aciona Foto, **Then** a aba fica selecionada e mostra a mesma estrutura com "Registrar por foto vem na próxima etapa do protótipo. Por enquanto, use Digitar.".
3. **Given** Falar ou Foto, **When** a pessoa aciona Digitar (na aba ou na ação), **Then** volta ao teclado com o tipo e o valor que tinha.
4. **Given** Falar ou Foto, **When** a pessoa observa a tela, **Then** nenhuma permissão de microfone, câmera ou fotos é pedida.

### Edge Cases

- O valor digitado vai até R$ 999.999,99, como no quadro. Um dígito que ultrapassaria o limite é ignorado. No campo de valor do formulário, vale o mesmo limite, e o valor é formatado enquanto se digita, como nos campos da configuração.
- Descrição com até 60 caracteres. Espaços nas pontas são removidos. Um gasto sem descrição aparece com o nome da categoria.
- A sugestão de categoria segue as palavras do quadro: Mercado (mercado, feira, hortifruti, sacolão), Restaurantes (café, restaurante, padaria, lanche, almoço, jantar, pizza, ifood), Transporte (uber, 99, ônibus, metrô, posto, gasolina, combustível), Saúde (farmácia, médico, consulta, dentista), Casa (aluguel, luz, água, internet, condomínio), Lazer (cinema, show, streaming, bar, viagem, jogo) e Compras (loja, roupa, tênis, livro). Sem correspondência, nenhuma categoria é pré-selecionada.
- A data não pode ser futura. "Outra data" abre um calendário até hoje, numa folha na altura do calendário; escolher o dia a fecha. Compromissos futuros pertencem às recorrências.
- Uma data anterior ao início do acompanhamento da conta é aceita, e o registro altera "Em contas hoje" do mesmo jeito. O tratamento do histórico anterior ao saldo inicial continua em aberto (`docs/descoberta.md`).
- Atribuição à fatura: uma compra até o dia do fechamento (inclusive) entra na fatura que fecha naquele mês; depois dele, na fatura que fecha no mês seguinte. Num mês sem o dia do fechamento (31 em novembro, por exemplo), o fechamento cai no último dia do mês. A fatura leva o nome do mês do vencimento. Fechamento depois do vencimento faz a fatura vencer no mês seguinte ao fechamento, como na configuração.
- Fatura aberta é a fatura de cada cartão que fecha no próximo fechamento a partir de hoje. Com vários cartões, Fatura soma as faturas abertas de todos.
- O mês de cada parcela é o mês da compra somado à posição da parcela menos um, independentemente da fatura em que ela entra.
- Com 0 registros, o Início continua como em `specs/003-month-summary/spec.md`.
- "Registros recentes" mostra os 5 registros mais recentes, por data e, no mesmo dia, pela ordem em que foram salvos. Inclui registros de meses anteriores e o salário recebido. Cada linha tem uma inicial colorida conforme a categoria ou a receita.
- "Para onde foi" › Gastos agrupa os gastos do mês por categoria, do maior para o menor, com a cor da categoria e o percentual arredondado. Receitas agrupa por descrição, com o salário recebido como "Salário".
- O balão da capivara no Início, com registros e sem salário a confirmar, diz "Seu mês está tomando forma, {primeiro nome}.". Ele não comenta o tamanho dos gastos nem repreende.
- Saldo do mês negativo aparece com "−" antes de "R$", e a água fica no nível mínimo, conforme a 003.
- Toques repetidos em "Salvar" ou "Continuar" não duplicam registros nem empilham telas.
- Se a gravação falhar, o registro não é dado como salvo: aparece "Não deu para salvar agora. Tente de novo." com "Tentar de novo", e o formulário é preservado.
- Com texto ampliado, o teclado, as categorias e os botões continuam utilizáveis, com rolagem do formulário. A barra de "Salvar" não cobre o último campo.
- Com redução de movimento, sem entrada animada das telas, sem cursor piscando e sem animação do aviso; todo conteúdo aparece direto.
- Com valores ocultos no Início, os registros recentes e as categorias também ocultam os valores. A tela de registro sempre mostra o valor que se digita.
- O registro funciona sem conexão.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: "Adicionar registro" DEVE abrir "Novo registro" na aba Digitar e no tipo Gasto, substituindo o destino provisório da 003. "Fechar e voltar ao resumo" DEVE voltar ao Início sem salvar.
- **FR-002**: O valor DEVE ser digitado no teclado próprio do quadro (1–9, 00, 0, apagar), em centavos exatos, de R$ 0,01 a R$ 999.999,99. "Continuar" só DEVE seguir com valor maior que zero.
- **FR-003**: O seletor Gasto ou Receita DEVE alterar a pergunta do valor e, no formulário, os campos disponíveis, conforme as histórias.
- **FR-004**: O formulário de gasto DEVE pedir valor, descrição opcional, uma de oito categorias (Mercado, Restaurantes, Transporte, Casa, Lazer, Saúde, Compras, Outros), "Pago com" e data. "Salvar" DEVE exigir valor maior que zero e categoria.
- **FR-005**: A categoria DEVE ser sugerida pela descrição, conforme os casos de borda, com a marca "sugerido". A sugestão nunca substitui uma escolha da pessoa.
- **FR-006**: O formulário de receita DEVE pedir valor, descrição opcional, "Entrou em" (só contas) e data, sem categoria nem parcelas.
- **FR-007**: "Pago com" DEVE listar as contas e os cartões do espaço, distinguindo conta e cartão como em Contas ("Cartão {nome}"), com a primeira conta selecionada.
- **FR-008**: Num cartão, o gasto DEVE ter de 1 a 12 parcelas, com o texto da fatura ou das parcelas descrito na US3. As parcelas DEVEM somar o total em centavos, com o resto na 1ª.
- **FR-009**: A data DEVE oferecer "Hoje", "Ontem" e "Outra data" (calendário até hoje). "Hoje" vem selecionado.
- **FR-010**: "Salvar" DEVE guardar o registro no aparelho, junto do espaço, mostrar o aviso "Registro salvo" com o resumo, a capivara comemorando e "Desfazer" por cerca de 4 segundos, e voltar ao teclado zerado. "Desfazer" DEVE remover o registro e restaurar o formulário.
- **FR-011**: Um gasto numa conta DEVE reduzir, e uma receita numa conta DEVE aumentar, "Em contas hoje". Um gasto no cartão NÃO DEVE alterar o dinheiro em contas. O pagamento da fatura não faz parte desta entrega.
- **FR-012**: Os totais do mês DEVEM contar as receitas e os gastos em conta com data no mês, as parcelas de cartão cujo mês é o mês atual e o salário recebido. O saldo inicial continua fora dos totais (FR-004 da 003).
- **FR-013**: O indicador Fatura DEVE mostrar a soma das parcelas das faturas abertas, conforme os casos de borda, e continuar distinto de Gastos.
- **FR-014**: "Registros recentes" e "Para onde foi" DEVEM mostrar os registros conforme os casos de borda e o quadro "Resumo do mês": a compra parcelada aparece pelo valor total nos recentes, e só a parcela do mês entra nas categorias.
- **FR-015**: As abas Falar e Foto DEVEM mostrar o aviso provisório da US5, sem simular reconhecimento, sem pedir permissões e sem criar registros.
- **FR-016**: A interface DEVE preservar paleta, tipografia, espaçamentos, componentes e interações do quadro "Novo registro", com as adaptações registradas: contas reais, calendário nativo em "Outra data", avisos de Falar e Foto e receita sem categoria.
- **FR-017**: Controles DEVEM ter nomes acessíveis e áreas de toque de pelo menos 44 por 44 pontos. As abas, o tipo, as categorias, as contas e a data DEVEM anunciar a seleção. O valor digitado DEVE ser anunciado ao mudar, e o aviso "Registro salvo" DEVE ser anunciado.
- **FR-018**: A redução de movimento DEVE remover as entradas animadas, o cursor piscando e a animação do aviso, sem perda de conteúdo.
- **FR-019**: O registro DEVE funcionar sem conexão, autenticação ou permissões, e não pode alegar acesso a dados bancários reais.
- **FR-020**: Espaços guardados antes desta funcionalidade DEVEM abrir normalmente, sem registros.

### Key Entities *(include if feature involves data)*

- **Registro**: Gasto ou receita confirmado pela pessoa. Tem valor total em centavos, descrição, data, conta ou cartão e momento em que foi salvo. O gasto tem categoria, e o gasto no cartão tem número de parcelas. É guardado no espaço.
- **Categoria**: Uma das oito categorias iniciais do quadro, com nome e cor. Criar e editar categorias ficam para depois.
- **Parcela**: Parte do valor de uma compra no cartão, com posição, valor, mês em que conta nos gastos e fatura a que pertence. Deriva do registro e não é guardada à parte.
- **Fatura**: Ciclo de um cartão, identificado pelo mês do vencimento. Deriva das datas do cartão.
- **Rascunho do registro**: Tipo, valor, campos do formulário e aba atual enquanto a pessoa registra. Existe somente durante a sessão e não é o "Rascunho de registro" de voz ou imagem do `CONTEXT.md`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Uma pessoa registra um gasto de categoria sugerida, na conta e hoje, com só dois toques além de digitar o valor e a descrição ("Continuar" e "Salvar"), em menos de 20 segundos desde o +.
- **SC-002**: Depois de salvar, 100% dos registros aparecem no Início com o valor exato em centavos e continuam iguais após reabrir o app.
- **SC-003**: Em qualquer combinação de registros, gastos no cartão nunca alteram "Em contas hoje", e o saldo inicial nunca entra nos totais do mês.
- **SC-004**: Em toda compra parcelada, a soma das parcelas é igual ao total, e cada mês conta só a sua parcela.
- **SC-005**: Após "Desfazer", nenhum vestígio do registro aparece no Início nem após reabrir o app.
- **SC-006**: Uma pessoa identifica, sem orientação, onde o gasto registrado aparece no Início.
- **SC-007**: Com leitor de tela, texto ampliado e redução de movimento, a pessoa registra um gasto e uma receita do começo ao fim.
- **SC-008**: Na comparação com o quadro "Novo registro", cabeçalho, abas, teclado, formulário, barra de ações e aviso preservam composição e estilo, com cada adaptação documentada.

## Assumptions

- O escopo corresponde à aba Digitar do quadro "Novo registro" de `design/App de finanças onsen — protótipo iPhone.html` (identificador `f5b9b259-abfa-43b6-993e-a9dc8456c772`), mais a apresentação dos registros no quadro "Resumo do mês" (`333f2428-5004-43ff-b703-276a4524089b`). O HTML original e seus avisos de licença serão preservados.
- Decisão do usuário em 2026-11-06: Falar, Foto, a leitura simulada e a revisão em lote ficam para a próxima funcionalidade.
- Decisão do usuário em 2026-11-06: a compra no cartão conta nos gastos do mês da compra, e cada parcela seguinte no mês seguinte. Isso define, para o protótipo, o "mês" das parcelas citado no `CONTEXT.md`. O ciclo exato da fatura continua em aberto. A regra de fechamento dos casos de borda é uma premissa desta entrega.
- Os registros são guardados no aparelho, como o espaço e o recebimento do salário, porque o Início só mostra dados reais (decisão da 003). Isso complementa a decisão de guardar a configuração no aparelho. A sincronização pelo iCloud continua fora.
- As oito categorias e suas cores vêm do quadro "Novo registro". O quadro "Resumo do mês" usa "Contas da casa" para a categoria que o registro chama de Casa; vale "Casa".
- A receita no quadro usa as mesmas categorias do gasto. Esta entrega a registra sem categoria e agrupa as receitas pela descrição, como o "Para onde foi" › Receitas do quadro. Essa é uma adaptação registrada.
- "Carteira" do quadro corresponde a uma conta do tipo dinheiro em espécie, quando existir no espaço. Não é criada automaticamente.
- "Outra data" no quadro apenas troca para uma data fixa. Esta entrega usa o calendário do iOS.
- Editar e excluir registros salvos, o detalhe de um registro e a lista completa de registros não estão no quadro e ficam fora desta entrega. "Desfazer" no aviso é a única correção.
- Não fazem parte desta entrega: Falar, Foto, revisão em lote, duplicatas, recorrências além do salário, pagamento de fatura, transferências entre contas, estornos, navegação entre meses, edição de categorias, metas, sincronização e exportação.

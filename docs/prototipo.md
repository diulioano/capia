# Primeira entrega: protótipo navegável

## Objetivo confirmado

Validar a compreensão das telas, o fluxo de registro e revisão, a personalidade da capivara e a intensidade das animações. Usar dados de exemplo; a primeira versão funcional virá depois, para o usuário e poucos convidados.

## Proposta de execução

Protótipo nativo para iPhone, escrito em Swift com interface em SwiftUI e dados de exemplo. A continuação adota xtool como ferramenta de compilação e instalação a partir do ambiente Windows. Esta decisão substitui a proposta anterior de protótipo web.

Em 2026-11-06, o usuário confirmou que já compilou um app padrão e o executou no iPhone. A validação inicial do caminho de compilação e instalação pelo xtool está atendida por esse relato; não precisa ser repetida como pré-requisito para iniciar as telas. Os comandos e as versões utilizados não foram fornecidos nesta conversa e devem ser registrados ao preparar a compilação deste projeto. O app deste repositório ainda precisará de sua própria validação no aparelho.

O protótipo funciona sem backend. Se a versão funcional precisar de um servidor, ele será desenvolvido em Java com Spring Boot. O envio a um serviço de IA é um possível motivo para essa necessidade, ainda a avaliar.

## Percurso proposto

1. Abrir o resumo mensal com receitas, gastos, faturas, registros recentes e acesso rápido a novo registro.
2. Escolher registro manual, por voz ou imagem. Voz e imagem usam resultados simulados claramente identificados, sem envio a IA nesta etapa.
3. Conferir um rascunho individual ou uma lista de gastos extraídos de uma fatura de exemplo. Editar campos, resolver uma possível duplicata, selecionar registros e confirmar a inclusão no resumo.
4. Consultar contas, cartões e uma compra parcelada; visualizar o efeito do pagamento de uma fatura sem duplicar o gasto.
5. Criar uma meta com nome e imagem, escolher prazo ou valor mensal, ordenar metas e confirmar uma sugestão de reserva. O progresso e o resumo refletem as ações na sessão.

## Critérios de avaliação

- A pessoa consegue registrar um gasto e identificar seu efeito no mês.
- A revisão em lote permite corrigir e excluir itens antes de confirmar.
- Receitas, gastos, previsões, pagamento de fatura e valores reservados são apresentados sem confundir seus significados.
- A capivara orienta e comemora; os movimentos acompanham as ações sem bloquear o uso e respeitam redução de movimento.
- Os dados de exemplo incluem conta, cartão, parcelas, recorrência prevista, possível duplicata e metas concorrendo por uma mesma sobra.
- A interface deixa explícita a simulação de reconhecimento e de planejamento; os resultados não alegam representar dados bancários reais.

## Limites desta entrega

Sem integração bancária, reconhecimento real por IA ou recuperação real por iCloud. Por decisão do usuário em 2026-11-06, a configuração inicial concluída é guardada somente no aparelho; os demais dados de exemplo continuam restritos à sessão até nova decisão. Esses recursos pertencem à etapa funcional. O protótipo será testado como app nativo no iPhone pelo xtool; a distribuição a convidados e a publicação ficam para uma etapa posterior. A exportação é uma decisão do produto; seu formato será definido antes de implementá-la.

O protótipo exportado do Claude em `../design/` define a referência visual para todo desenvolvimento. A implementação em SwiftUI deve seguir suas telas, componentes e fluxos, conforme `../AGENTS.md`. Os recursos visuais existentes estão em `../assets/`.

O nome escolhido pelo usuário em 2026-11-06 é Capia. O HTML original permanece preservado, inclusive quando usa nomes anteriores à escolha.

## Primeira funcionalidade especificada

Get Started concluído em 2026-11-06 na build 5. O projeto foi criado por `xtool new Capia --skip-setup`; compilação e seis testes de navegação passaram. O usuário aprovou as três histórias e a conferência integrada no iPhone: boas-vindas, apresentação, entrada provisória da configuração, ícone e reabertura, incluindo uso sem rede e acessibilidade. Os demais fluxos deste documento continuam propostos. Comandos e evidências estão em `../specs/001-get-started/quickstart.md` e `../specs/001-get-started/validation.md`.

A implementação começa pelo fluxo Get Started: boas-vindas e três etapas de apresentação, conforme o primeiro quadro do HTML. O ícone do Capia usará `../assets/capybara-onsen.png` como base, com adaptação de enquadramento para identificação na tela inicial do iPhone.

A especificação está em `../specs/001-get-started/spec.md`. O cadastro de nome da pessoa, preferências, primeira conta e cartão pertence ao próximo fluxo. As tarefas de estrutura e comportamento serão separadas das tarefas de interface e fidelidade visual no planejamento.

## Segunda funcionalidade: configuração inicial

Implementada e aprovada pelo usuário no iPhone em 2026-11-06, por US (nome e objetivos, conta e saldo, cartão e datas, conclusão e reabertura). Durante a US3 o usuário decidiu sugerir o vencimento 7 dias após o fechamento e avisar, sem bloquear, fora de 5 a 15 dias. Evidências em `../specs/002-initial-setup/validation.md`.

Configuração inicial do espaço: nome, objetivos, primeira conta com saldo inicial, cartão de crédito separado com fechamento e vencimento e conclusão com resumo, conforme o quadro "Configuração inicial" do HTML. Substitui a entrada provisória do Get Started. A especificação está em `../specs/002-initial-setup/spec.md`.

## Terceira funcionalidade: resumo do mês

Em andamento em 2026-11-06, especificada em `../specs/003-month-summary/spec.md`. Por decisão do usuário, o Início mostra só os dados reais do espaço, sem registros de exemplo; isso substitui, para esta tela, a proposta de dados de exemplo acima. US1–US4 (visão do mês, seções vazias, ocultar valores, navegação) foram aprovadas pelo usuário no iPhone. A US5 acrescenta o salário mensal como sétima etapa da configuração (complementa as seis etapas de `../specs/002-initial-setup/spec.md`), confirmado com "Recebi" no Início, e mostra o dinheiro em contas hoje.

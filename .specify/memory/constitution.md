# Constituição do Capia

## Core Principles

### I. App nativo com cadeia de compilação comprovada

O app para iPhone DEVE ser desenvolvido em Swift com SwiftUI. O HTML de referência
orienta a interface e não define a tecnologia de implementação.

Antes de construir as telas, a equipe DEVE comprovar a compilação, a instalação e a
abertura de um app mínimo no iPhone pelo xtool a partir do ambiente Windows atual.
Essa validação DEVE registrar os comandos, os requisitos do ambiente e o resultado
observado. Uma tentativa de compilação ou a geração de um pacote, isoladamente,
não comprova instalação e execução.

Se houver necessidade de backend próprio, ele DEVE usar Java com Spring Boot.
A existência dessa escolha não exige criar um servidor para o protótipo.

### II. Design de referência e acessibilidade nativa

Todo desenvolvimento de interface DEVE partir de `design/`. A referência atual é
`design/App de finanças onsen — protótipo iPhone.html`, exportada do Claude.
Antes de implementar ou alterar uma tela, a equipe DEVE identificar o fluxo
correspondente e consultar sua composição, cores, tipografia, espaçamentos,
componentes, mascote e interações.

A implementação DEVE preservar essa direção visual ao adaptá-la aos componentes
nativos do iOS e à acessibilidade. As animações DEVEM respeitar a preferência de
redução de movimento e não podem bloquear registro ou revisão. A capivara orienta
e comemora sem repreender a pessoa nem exigir cuidados.

Ao concluir uma tela, a equipe DEVE compará-la à referência. Estados ausentes do
HTML DEVEM seguir o mesmo sistema visual e as regras de produto. Complementos e
adaptações DEVEM ser registrados no plano ou na documentação da funcionalidade.
Os recursos correspondentes em `assets/` DEVEM ser reutilizados. O HTML original
e seus avisos de licença DEVEM ser preservados.

### III. Significados financeiros preservados

`CONTEXT.md` define o vocabulário obrigatório do domínio. Modelos, dados de exemplo,
cálculos e textos da interface DEVEM manter suas distinções:

- Conta e cartão de crédito são entidades distintas, mesmo quando pertencem ao mesmo banco.
- O resumo mensal considera as parcelas nas respectivas faturas. O detalhe da compra
  preserva o valor total.
- Pagar uma fatura reduz o saldo da conta e quita a fatura sem gerar um segundo gasto.
- Uma recorrência prevista só altera o saldo após confirmar recebimento ou pagamento.
- Saldo em conta, sobra do período e valor reservado para meta têm significados distintos.
  Uma reserva não é gasto nem transferência bancária executada pelo app.
- A sugestão para metas considera compromissos e prioridades, sem atribuir a mesma
  sobra integralmente a várias metas.
- Voz e imagem produzem rascunhos para revisão. Nada é salvo como registro confirmado
  sem confirmação explícita. Possíveis duplicatas são sinalizadas para decisão da pessoa.

Questões financeiras ainda abertas em `docs/descoberta.md` DEVEM permanecer explícitas.
Uma simulação no protótipo não pode ser apresentada como regra definitiva do produto.

### IV. Protótipo navegável antes de integrações reais

A primeira entrega DEVE ser um protótipo nativo navegável, com dados de exemplo e
sem backend. As ações DEVEM atualizar o estado da sessão para permitir avaliar os
fluxos documentados em `docs/prototipo.md`. Os dados que a pessoa informa e confirma,
como perfil, contas e cartões, PODEM ser guardados somente no aparelho, para que o app
os preserve ao ser reaberto. Isso não é integração: sincronização e recuperação pelo
iCloud continuam fora da entrega até decisão própria.

Reconhecimento por voz e imagem e sugestões de planejamento DEVEM ser identificados
como simulações. Integração bancária, reconhecimento real por IA e recuperação real
por iCloud ficam fora desta entrega. O protótipo não pode alegar usar dados bancários
reais nem enviar voz ou imagens a um serviço de IA.

O esqueleto DEVE conter apenas a estrutura necessária aos fluxos previstos. Serviços,
camadas e dependências de produção exigem uma necessidade concreta da etapa em curso.

### V. Estrutura primeiro, tarefas separadas e entregas verificáveis

O trabalho DEVE separar tarefas de estrutura e comportamento das tarefas de interface
e fidelidade visual, com dependências explícitas entre elas. Essa separação organiza
a execução e não permite declarar um fluxo concluído antes de verificar ambos.

Depois de validar o app mínimo, a equipe DEVE preparar o esqueleto necessário à
navegação, aos modelos do domínio, ao estado da sessão e aos dados de exemplo.
O esqueleto DEVE permitir abrir o app e percorrer as entradas dos fluxos planejados.
Telas provisórias servem à validação dessa estrutura e não contam como telas finalizadas.

Cada tarefa DEVE indicar um resultado observável, suas dependências e uma forma de
verificação. Telas e fluxos DEVEM ser implementados em unidades que possam ser
avaliadas no app. Mudanças em cálculos e transições financeiras DEVEM ter testes
automatizados de comportamento. A validação visual e de interação DEVE ocorrer no
app nativo, incluindo redução de movimento nos fluxos animados.

## Restrições de produto

Antes de desenvolver funcionalidades, a equipe DEVE ler `CONTEXT.md`,
`docs/descoberta.md` e `docs/prototipo.md`, além das instruções de `AGENTS.md`.
Esses documentos registram o vocabulário, as decisões e o escopo que orientam
especificações e planos. Intenções ainda abertas não são requisitos confirmados.

O nome do produto é Capia, escolhido pelo usuário em 2026-11-06. A identificação
do app DEVE usar esse nome. Nomes anteriores presentes no repositório ou no HTML
não substituem essa decisão. O HTML de referência permanece preservado.

## Fluxo de desenvolvimento

Especificações, planos e tarefas DEVEM seguir esta sequência de dependências:

1. Delimitar a entrega e seus critérios de aceitação a partir da documentação e do design.
2. Comprovar compilação, instalação e abertura do app mínimo pelo xtool no iPhone.
3. Construir e verificar o esqueleto com navegação e dados de exemplo.
4. Implementar cada fluxo com tarefas separadas para comportamento e interface.
   As tarefas de interface DEVEM apontar a tela ou interação de referência em `design/`.
5. Verificar o fluxo completo, as regras financeiras afetadas, a fidelidade visual e
   a acessibilidade antes de marcá-lo como concluído.

O plano DEVE registrar a conformidade com estes princípios e justificar eventuais
exceções. As tarefas DEVEM refletir os limites do protótipo. Uma validação bloqueada
DEVE ser registrada como pendente, com seu motivo, sem ser marcada como concluída.

## Governance

Esta constituição registra os princípios do projeto e orienta o trabalho do Spec Kit.
Uma instrução posterior do usuário prevalece sobre estas regras. Quando uma decisão
mudar, a equipe DEVE atualizar a constituição e a documentação afetada antes de tratar
a nova orientação como regra permanente.

Cada alteração DEVE registrar sua motivação, o impacto sobre o trabalho existente e
a nova versão. A versão segue o formato MAJOR.MINOR.PATCH: MAJOR para remoção ou
redefinição incompatível de princípios, MINOR para novas regras ou ampliação material
e PATCH para esclarecimentos sem mudança de obrigação.

Na revisão de especificações, planos, tarefas e implementação, a equipe DEVE conferir
conformidade com a constituição. Exceções DEVEM identificar a regra afetada, a razão
e o alcance. Não é permitido omitir uma verificação exigida e declarar a entrega concluída.

A emenda 1.0.1 registra a escolha do nome Capia pelo usuário e atualiza a identificação
do produto. A mudança substitui a identificação provisória sem alterar os princípios
técnicos ou o escopo da entrega.

A emenda 1.1.0 permite guardar no aparelho os dados informados pela pessoa. Motivação:
o usuário apontou em 2026-11-06 que, sem isso, a pessoa não teria como manter seus dados,
e decidiu deixar a sincronização pelo iCloud para depois. Impacto: a configuração inicial
(funcionalidade 002) grava o espaço concluído; o Get Started validado não muda.

**Version**: 1.1.0 | **Ratified**: 2026-11-06 | **Last Amended**: 2026-11-06

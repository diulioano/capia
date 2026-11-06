# Modelo de dados: Get Started do Capia

Não há dados financeiros, persistência ou tráfego externo nesta funcionalidade.
Os tipos abaixo são o contrato da navegação; as views renderizam esse estado.

## Tipos e responsabilidades

| Tipo | Valores ou campos | Responsabilidade |
|------|-------------------|------------------|
| `IntroStep` | `register`, `monthlyOverview`, `goals` | Definir as três etapas válidas, sua ordem e posição 1 a 3 |
| `GetStartedScreen` | `welcome`, `introduction(IntroStep)`, `configurationEntry(origin: IntroStep)` | Determinar a tela visível e preservar a origem do destino provisório |
| `GetStartedFlow` | `screen: GetStartedScreen`, inicialmente `welcome` | Aplicar transições de navegação síncronas e puras |
| `GetStartedAction` | começar, continuar, voltar, pular, configurar, retornar da configuração | Expressar intenções a partir da tela de origem |
| Feedback local da welcome | identificador do toque e tarefa cancelável, sem persistência | Mostrar a mensagem por 1,9 segundo e renovar ao receber novo toque |

A fronteira pública do pacote puro é o estado de tela e uma operação de transição de
estado por ação. Não há protocolo de serviço nem dependência de SwiftUI ou UIKit.
Textos, cores, nomes das imagens e fontes pertencem ao pacote de interface, não ao fluxo.

## Regras de validade

- A tela inicial é sempre `welcome` em uma nova execução do app.
- Não se representa etapa por inteiro livre ou por vários booleanos de tela.
- A entrada provisória exige uma `IntroStep` como origem. Não existe origem ausente.
- Progresso é derivado da etapa: registro 1, resumo 2 e metas 3. Não é outro estado mutável.
- A ação carrega a tela de onde foi emitida. Se essa origem não é mais a tela atual,
  a ação não muda o estado. Isso evita processar duas vezes o mesmo toque durante troca de tela.
- Ações sem sentido na tela atual não mudam o estado; não avançam além dos limites do fluxo.
- Não há pilha de telas duplicadas. Apenas um caso da enumeração está ativo.
- O estado de navegação pertence à raiz `GetStartedView` em `@State` e é alterado no ator principal.

## Transições observáveis

| Origem | Ação | Destino |
|--------|------|---------|
| Boas-vindas | Começar | Introdução registro |
| Introdução registro | Continuar | Introdução resumo |
| Introdução resumo | Continuar | Introdução metas |
| Introdução registro | Voltar | Boas-vindas |
| Introdução resumo | Voltar | Introdução registro |
| Introdução metas | Voltar | Introdução resumo |
| Qualquer introdução | Pular | Configuração provisória com a etapa atual como origem |
| Introdução metas | Configurar meu espaço | Configuração provisória com metas como origem |
| Configuração provisória | Voltar à apresentação | Introdução preservada como origem |
| Qualquer tela | Ação incompatível ou de origem antiga | Mesma tela |

## Ciclo de vida do feedback

O feedback é exclusivo de `WelcomeView`. Tocar na capivara mostra "Que bom te ver aqui."
e reinicia sua duração. Uma tarefa anterior cancelada não pode esconder a mensagem
renovada. Ao sair, cancelar a tarefa e remover o feedback. Voltar cria uma welcome sem
balão antigo. A preferência de reduzir movimento não altera esse comportamento.

A UI mantém esse tempo fora do modelo puro. O comportamento é validado no app por toques
repetidos e saída imediata; não é necessário criar um serviço de relógio para um balão.

## Conteúdo ilustrativo

A introdução usa constantes locais, sem entidades de conta ou transação: categorias
Mercado 35%, Restaurantes 20%, Transporte 13% e Lazer 11%; meta "Viagem ao Japão",
R$ 12.240 de R$ 18.000, 68%. São exemplos parciais de apresentação, não um extrato real
nem categorias que devam somar 100%. Uma indicação discreta de exemplo acompanha as
ilustrações e integra sua descrição acessível.

## Testes planejados

Os testes do pacote puro verificam o percurso completo, todos os retornos, Pular de cada
etapa, retorno da entrada provisória, reinício por nova instância e ações repetidas com
origem antiga. As asserções observam a tela resultante, sem exigir armazenamento interno
ou uma implementação específica do reducer.

# Contrato de interface: Get Started do Capia

Referência: primeiro quadro de `design/App de finanças onsen — protótipo iPhone.html`,
identificador `d017ec14-a843-4b61-ab79-5bedc20a48eb`, tamanho base 390 × 844.
Requisitos cobertos: FR-001 a FR-015 de [spec.md](../spec.md).
Este é um contrato de interface local; não há API HTTP ou integração externa.

## Composição e recursos

| Elemento | Referência base | Adaptação nativa |
|----------|-----------------|------------------|
| Fundo | Creme `#FBF4E5`, cena vertical onsen | Imagem ocupa o fundo; controles respeitam área segura |
| Tipografia | Figtree no corpo, Zen Maru Gothic nos títulos | Fontes locais, pesos reais e escala com Dynamic Type |
| Texto | Principal `#2E2A25`, apoio `#5E564D` | Conferir contraste real com a imagem e tamanhos acessíveis |
| Ação | Verde `#5C6B34`, texto `#FBF7F0`, altura 58, raio 20 | Altura mínima da referência, podendo crescer com o texto |
| Cartões da introdução | Altura 400, raio 32, fundos por etapa | Preservar proporção no tamanho base; rolar conteúdo em tamanhos ampliados |
| Mascote welcome | Capivara extraída do HTML, carinho ao toque | Botão acessível com área de pelo menos 44 × 44 pontos |
| Navegação | Voltar, Pular, indicador de três etapas e ação final | Ordem de leitura lógica; progresso anunciado como uma unidade |

Textos principais têm o conteúdo exato da referência. Não acrescentar uma logomarca
onde o quadro não prevê uma. A identificação instalada usa Capia.

## Boas-vindas

A hierarquia inicial é "Boas-vindas ao seu refúgio", "Seu dinheiro em águas calmas.",
"Registre gastos, entenda o mês e guarde para o que importa, sem planilha e sem pressa.",
"Não precisa criar conta" e Começar.

No tamanho base, o bloco textual parte do recuo horizontal de 28 pontos, com título
34 e corpo 16. O botão Começar tem recuos laterais de 24. A posição da capivara deve
ser ancorada à cena e à água, usando a proporção de recorte do fundo; não à área textual.
Aumentar fonte não pode deslocar o alvo de toque para fora da imagem correspondente.

Vapor, brilho, reflexo e ondulações acompanham a cena sem interceptar toques. A ação
"Fazer carinho na capivara" produz "Que bom te ver aqui." por 1,9 segundo. O balão não
bloqueia Começar e desaparece ao sair. Em texto ampliado, priorizar leitura e acesso
às ações, permitindo reorganização registrada em vez de sobreposição sobre o título.

## Três etapas de apresentação

O contêiner compartilha Voltar, Pular, painel ilustrado, título, descrição, progresso
e ação inferior. Voltar da primeira etapa retorna às boas-vindas.

| Etapa | Conteúdo ilustrado e textual | Ação principal |
|-------|------------------------------|----------------|
| 1. Registre do seu jeito | Capivara e opções Digitar, Falar, Foto do recibo; rascunho que a pessoa confere | Continuar |
| 2. Entenda para onde vai | Resumo de Novembro com categorias da referência; receitas, gastos, faturas e previsões | Continuar |
| 3. Metas sem aperto | Meta Viagem ao Japão, 68%, R$ 12.240 de R$ 18.000; sugestão mensal de reserva | Configurar meu espaço |

Digitar, Falar, Foto do recibo, barras e meta são ilustrações, não controles de captura,
edição ou transação. Uma indicação discreta "Exemplo" e uma descrição acessível informam
essa condição sem criar dados financeiros da pessoa.

Os blobs das poses do componente Capivara não estão incluídos no HTML exportado.
As poses pensando, feliz e comemorando são preparadas das células correspondentes
da folha de expressões existente em `assets/`, conforme permitido nas tarefas.
O script registra origem e transformação; a alternativa precisa da conferência visual no aparelho.

Em tamanhos de texto de acessibilidade, o painel mantém sua composição e ganha abaixo
uma descrição ampliada com todos os valores do exemplo. Essa descrição é a leitura
assistiva do exemplo nesse modo, evitando repetição dos rótulos internos.

## Entrada provisória da configuração

Pular de qualquer introdução e Configurar meu espaço da terceira chegam a uma tela
local com o mesmo creme, tipografia e componente de ação. Essa tela apresenta
"A configuração do seu espaço vem na próxima etapa do protótipo." e o botão
"Voltar à apresentação". O botão retorna à etapa que abriu essa entrada.

Essa composição complementa o design e não implementa o segundo quadro. Não solicitar
nome, primeira conta, cartão, autenticação ou permissão nesta funcionalidade.

## Acessibilidade e movimento

- Progresso como um elemento "Etapa N de 3"; pontos individuais são decorativos.
- Foco do VoiceOver no título após trocar de tela; feedback da capivara anunciado uma
  vez por toque, sem retirar acesso ao botão. Não anunciar partículas ou reflexos.
- Botões com alvo mínimo de 44 × 44 pontos; texto cresce sem truncar a ação final.
- Com redução de movimento, cena estática e troca de conteúdo sem deslocamentos;
  gráficos já mostram seus valores finais. Nenhuma ação aguarda animações.
- Na configuração padrão, transições discretas preservam os movimentos da referência.
  Animações contínuas só existem enquanto a tela correspondente está visível.
- Em telas pequenas e texto ampliado, rolagem conserva todos os textos e ações.
  O rodapé reserva espaço para não encobrir o último conteúdo.

Na welcome com texto de acessibilidade ou pouca altura disponível, o texto e a cena
formam uma coluna rolável, enquanto Começar permanece em um rodapé que respeita a
área segura. A cena usa um recorte proporcional compartilhado por fundo, mascote,
reflexo e efeitos, com transição suave para o creme. O feedback de carinho ocupa uma
área reservada acima da cena nesse modo, sem cobrir o mascote nem deslocá-lo ao aparecer.
O texto continua usando o tamanho escolhido nos Ajustes.

## Ícone e recursos instalados

Master do ícone em PNG opaco de 1024 × 1024, baseado em `assets/capybara-onsen.png`,
com fundo creme coerente, rosto e toalha preservados e sem texto miúdo ou máscara
arredondada desenhada. Configuração no bundle principal por `iconPath` do xtool.

Todas as imagens e fontes ficam empacotadas. Nenhum link remoto do HTML é dependência
de execução. O original e seus avisos de licença permanecem intactos. Licenças de
fontes e registro das origens acompanham os recursos derivados.

## Verificação

[quickstart.md](../quickstart.md) define os percursos. A implementação só atende a este
contrato depois de verificar comportamento, composição e acessibilidade no app nativo.

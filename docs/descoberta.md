# Descoberta do produto

## Direção trazida pelo usuário

- App para iOS voltado ao controle financeiro pessoal.
- Registrar gastos por voz, imagem ou preenchimento manual.
- Reconhecer a natureza do gasto e permitir separar gastos por banco.
- Ter um planejador para guardar dinheiro e indicar quanto poupar.
- Explorar animações e escolher um mascote para o app.

## Possibilidades ainda não decididas

- Integração bancária somente para leitura, possivelmente em uma v2.
- Ajustes da aparência do mascote e das animações durante a validação do protótipo. A referência visual atual está em `../design/`.
- Fórmula detalhada e horizonte da previsão usada para sugerir quanto poupar.

## Público inicial

Confirmado pelo usuário: o app deve atender a ele próprio e também a quem quer manter uma planilha de controle financeiro. A rotina do usuário será a referência inicial para discutir os fluxos.

O app substituirá a planilha, com exportação dos registros para uso fora do app. Formato e campos da exportação ainda não foram definidos. Não foi solicitada sincronização nem importação de planilhas.

## Decisões confirmadas

- O resultado principal da primeira versão é registrar facilmente e entender para onde o dinheiro vai.
- O app terá registro de receitas e gastos. O planejamento deve considerar o dinheiro disponível a partir dessas informações.
- Contas e cartões de crédito serão separados, mesmo quando pertencem ao mesmo banco.
- Registros recebidos por voz ou imagem serão apresentados como rascunho para confirmação antes de salvar.
- A v1 acompanhará compras parceladas, com parcelas nos meses seguintes.
- O resumo mensal considera o valor das parcelas atribuídas às faturas daquele mês; o detalhe da compra preserva seu valor total.
- O pagamento da fatura será vinculado a uma conta: reduz seu saldo e quita a fatura, sem contabilizar novamente os gastos que a compõem.
- Cada cartão terá datas de fechamento e vencimento. O app sugere a fatura da compra, com possibilidade de correção pelo usuário.
- Ao cadastrar uma conta, a pessoa informa o saldo inicial, sem precisar cadastrar todo o histórico anterior.
- Receitas e despesas recorrentes geram previsões. Só alteram o saldo quando o recebimento ou pagamento é confirmado.
- As metas de economia terão nome e poderão usar uma foto da pessoa ou uma imagem padrão oferecida pelo app.
- O plano da meta terá dois caminhos: valor desejado e prazo para calcular o valor mensal; ou valor desejado e valor mensal para estimar a data.
- O mascote será um companheiro que orienta e comemora conquistas, sem exigir cuidados.
- Haverá um único mascote como identidade do app, escolhido durante o design do produto.
- O app sugere quanto reservar considerando receitas, gastos e compromissos previstos; a pessoa confirma o valor destinado à meta.
- Havendo várias metas, a pessoa escolhe a prioridade. A distribuição proposta atende primeiro o valor mensal da meta prioritária e depois as demais.
- Confirmar um valor reservado registra sua destinação à meta no app; não constitui gasto nem movimentação bancária executada pelo app.
- A leitura por imagem incluirá comprovantes e recibos individuais, além de prints de extratos e faturas com vários gastos.
- A v1 não exigirá uma conta própria do app; usará iCloud para recuperação dos dados ao trocar de iPhone. A solução técnica e seu comportamento sem iCloud ainda precisam ser definidos.
- Voz e imagens poderão ser enviadas a um serviço de IA para reconhecimento, com informação clara sobre o envio. Provedor, custo e retenção dos arquivos ainda não foram definidos.
- Possíveis duplicatas serão sinalizadas para decisão da pessoa; não serão descartadas automaticamente.
- Haverá categorias iniciais prontas, com opção de criar e editar. O reconhecimento sugere uma categoria que a pessoa pode corrigir.
- Na importação em lote, a pessoa revisa uma lista de gastos, abre registros individualmente quando necessário e confirma o conjunto selecionado ao terminar.
- O app substituirá a planilha e permitirá exportar os registros para uso externo.
- A tela inicial dará destaque ao resumo do mês: receitas, gastos e faturas, com acesso rápido ao registro.
- O mascote a explorar será uma capivara de personalidade tranquila e acolhedora.
- A direção de animação mistura presença expressiva do mascote e comemorações com movimentos em transições, gráficos e interações do dia a dia.
- A primeira entrega será um protótipo navegável com dados de exemplo para validar telas e movimentos, antes do app funcional.
- O usuário tem iPhone, mas não tem acesso a Mac. O ambiente atual do projeto é Windows.
- O app será nativo, desenvolvido em Swift com interface em SwiftUI. O usuário utiliza xtool, que será o caminho inicial de compilação e instalação no iPhone.
- A primeira entrega também será nativa em Swift, substituindo a proposta anterior de protótipo web. Em 2026-11-06, o usuário confirmou que já compilou um app padrão e o executou no iPhone, atendendo à validação inicial antes da construção das telas. A compilação do app deste repositório ainda será verificada durante a implementação.
- Se houver necessidade de backend próprio, a tecnologia escolhida é Java com Spring Boot. O protótipo com dados de exemplo não depende de servidor.
- A primeira versão funcional será destinada ao usuário e a poucos convidados em teste.

## Diretrizes de interação propostas

- Animações acompanham as ações sem exigir que a pessoa espere para registrar ou revisar gastos.
- O mascote orienta e comemora sem repreender a pessoa por gastos ou metas atrasadas.
- Respeitar a preferência de reduzir movimento do aparelho; a informação deve continuar compreensível sem animações.

Essas diretrizes traduzem a direção escolhida em critérios para a interface. O protótipo em `../design/` é a referência visual de desenvolvimento; a duração e a intensidade dos movimentos serão avaliadas no app nativo.

## Fluxo confirmado de revisão da importação

Um gasto isolado abre um único rascunho. A importação em lote abre uma lista selecionável e editável, destacando registros com campos ausentes, leituras duvidosas e possíveis duplicatas. A pessoa pode abrir qualquer registro para revisão individual; nada é salvo sem confirmação explícita. A escolha do fluxo foi confirmada pelo usuário após discutir a alternativa de revisar obrigatoriamente um gasto por vez.

## Distinções do planejador

O usuário propôs usar ganhos menos gastos como base do planejador e confirmou que a sobra deve gerar uma sugestão de reserva, sujeita à confirmação. Não foi escolhido vincular metas a contas específicas.

O cálculo deve distinguir sobra do período, saldo em conta e valor reservado para uma meta. Compromissos previstos e faturas pendentes precisam de tratamento explícito para não apresentar dinheiro comprometido como disponível. Se houver várias metas, a mesma sobra não pode ser atribuída integralmente a cada uma.

## Próximas decisões

O necessário para delimitar o protótipo foi discutido. A continuação está descrita em `prototipo.md`, com Swift, SwiftUI e xtool. Após confirmar a execução do app padrão no iPhone, o usuário escolheu começar pelo Get Started e pelo ícone do app. A base escolhida para o ícone é `../assets/capybara-onsen.png`. Em 2026-11-06, o usuário escolheu Capia como nome do produto.

Pontos a resolver antes da versão funcional: fórmula e horizonte do planejador, manutenção e retirada de valores reservados, tratamento de faturas anteriores ao início do acompanhamento, transferências entre contas, estornos, reconciliação de recorrências com importações, datas e limites dos ciclos de fatura, formato da exportação, serviço de IA e seus custos/retenção, comportamento sem iCloud e caminho de compilação/distribuição iOS. Esses pontos não precisam ser simulados como integrações reais no protótipo.

Nenhuma implementação iniciada. As intenções acima não constituem escopo fechado.

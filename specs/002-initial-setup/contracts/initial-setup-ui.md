# Contrato de interface: Configuração inicial do espaço

Referência: quadro "Configuração inicial" de `design/App de finanças onsen — protótipo iPhone.html`,
identificador `fe19fbe7-038d-4ef6-bb17-aedea28b4d3f`, tamanho base 390 × 844.
Requisitos cobertos: FR-001 a FR-019 de [spec.md](../spec.md). Contrato de interface local;
não há API HTTP ou integração externa.

## Contêiner das etapas

| Elemento | Referência base | Adaptação nativa |
|----------|-----------------|------------------|
| Fundo | Creme `#FBF4E5`, recuo 58 no topo e 20 nas laterais | Respeita área segura; conteúdo rola quando necessário |
| Voltar | Botão 44 × 44, raio 14, fundo `#F1E6D2`, chevron `#2E2A25` | "Voltar"; na primeira etapa leva à apresentação de origem |
| Progresso | Barra de 6 pt, raio 3, trilho `#E8DBC6`, preenchimento `#5C6B34`, largura N/6, transição 0,5 s | "Progresso da configuração, etapa N de 6"; sem animação com redução de movimento |
| Capivara | 84 × 84 à esquerda, alinhada à base do balão | Pose pelo humor derivado; decorativa para VoiceOver |
| Balão de dica | Fundo `#FFFCF5`, raio 16/16/16/4, sombra suave, 14 pt, `#4A433B`; aparece com fade | Lido como texto; muda por etapa |
| Título | Zen Maru Gothic 28 (26 nas datas), entrada com `enter` | Cabeçalho acessível; foco ao trocar de etapa |
| Continuar | Fixo a 34 do rodapé, altura 58, raio 20; ativo `#5C6B34`/`#FBF7F0`, inativo `#DDD3C4`/`#6B6258` | Acompanha o teclado; anunciado como indisponível quando inválido |

Opção selecionável (objetivos, tipos, cartão): fundo `#FFFCF5` e borda 2 `#E5D6BE`;
selecionada, fundo `#ECEBD6` e borda `#5C6B34`; anuncia "selecionado".

## Etapas

| # | Título | Conteúdo | Dica da capivara |
|---|--------|----------|------------------|
| 1 | Como podemos te chamar? | Rótulo "Nome ou apelido", campo sublinhado 60 pt, placeholder "Ex.: Diuli", selo verde ao validar, "Só mais uma letrinha." em `#9C4A22` | Oi! Vamos arrumar seu cantinho. |
| 2 | {Primeiro nome}, o que te trouxe aqui? | Quatro opções com caixa de seleção 26 × 26, altura mínima 60, raio 18 | Pode escolher mais de um. |
| 3 | Vamos cadastrar sua primeira conta | Grade de 3 tipos (96 pt, raio 18, ícone 26), rótulo do nome conforme tipo, placeholder "Ex.: Banco Aurora", "Você pode adicionar outras contas depois." | Comece pela conta que você mais usa. |
| 4 | Quanto tem hoje em {conta}? | "Saldo inicial" centralizado, valor grande em Zen Maru Gothic, cinza `#9A8F82` quando zero; atalhos em pílulas 44 pt; "Pode ser zero ou aproximado. Você ajusta quando quiser." | Pode ser um valor aproximado. |
| 5 | Você usa cartão de crédito de {conta}? | "Sim, tenho cartão" / "Acompanho a fatura separada da conta"; "Agora não" / "Dá para adicionar depois"; cartões 76 pt, raio 20 | Cartões ficam separados da conta, mesmo no mesmo banco. |
| 6 | Datas do cartão {conta} | "Fecha no dia" e "Vence no dia", fileiras horizontais 1…31 (48 × 52, raio 16; selecionado verde); aviso verde `#ECEBD6`/`#45512A` ou erro `#FADDCB`/`#84401E` com tremor | Assim eu sei em qual fatura cada compra cai. |

As fileiras de dias rolam até o dia selecionado ao abrir e quando o vencimento é sugerido.
Complementos (decisão de 2026-11-06): o aviso verde acrescenta "A fatura vence no dia Y do
mês seguinte." quando for o caso; distância fora de 5 a 15 dias mostra, abaixo, em areia
`#F1E6D2` com texto `#9C4A22`, "Costuma haver de 5 a 15 dias entre o fechamento e o
vencimento. Confira as datas na sua fatura.", sem bloquear Continuar. O tremor do erro é omitido com
redução de movimento; o texto permanece.

## Conclusão

Fundo `#F1E8DA`; 18 confetes nas cores `#5C6B34`, `#C4622E`, `#D99A3C`, `#7FB3A5`,
`#C9A472`, caindo uma vez; capivara comemorando 180 × 180; "Tudo pronto, {primeiro nome}!"
(Zen Maru Gothic 30) e o texto de apoio; cartão branco `#FFFCF5`, raio 22, com:

- Para cada conta: nome em negrito, tipo por extenso, saldo inicial alinhado à direita em
  algarismos tabulares.
- Para cada cartão: "Cartão {nome}", "Fecha dia X · vence dia Y" e selo "Separado"
  (`#ECEBD6`/`#45512A`).
- Sem cartões: "Sem cartão por enquanto.".

Ações: "Ver meu mês" (primária) e "Adicionar outra conta" (texto verde `#5C6B34`, 48 pt).
Voltar no topo apenas quando há rascunho (não restaurado), como complemento ao design, que
não o mostra; leva às datas ou à pergunta do cartão.

Com redução de movimento: sem confete, sem `pop`/`enter`; conteúdo aparece direto. Confete
oculto ao VoiceOver; o resumo é lido como lista, um item por conta ou cartão.

## Complementos ao design

- **Destino de "Ver meu mês"** (`MonthPlaceholderView`): mesmo padrão da antiga entrada
  provisória: "O resumo do seu mês vem na próxima etapa do protótipo." e "Voltar ao
  resumo". É também a tela de abertura com espaço guardado.
- **Falha ao guardar**: na conclusão, aviso `#FADDCB`/`#84401E`: "Não consegui guardar no
  aparelho. Seus dados ficam só até fechar o app." com "Tentar de novo".
- **Outra conta**: Voltar na etapa da conta retorna à conclusão sem mudanças; a barra mostra
  etapa 3 de 6.
- Voltar na primeira etapa não leva à tela Main do HTML, e sim à apresentação de origem.

## Acessibilidade e movimento

- Alvos de pelo menos 44 × 44; tudo cresce com Dynamic Type e rola sem truncar.
- Foco no título ao trocar de etapa; mensagens de validação anunciadas quando aparecem.
- Teclados: nome com iniciais maiúsculas e sem autocorreção; banco sem autocorreção;
  saldo numérico. "Continuar" no teclado só avança com etapa válida.
- Redução de movimento: sem transições deslizantes, preenchimento animado da barra,
  `pop`, tremor ou confete; nenhuma ação espera animação.

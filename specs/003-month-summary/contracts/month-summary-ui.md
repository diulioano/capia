# Contrato de interface: Resumo do mês

Referência: quadro "Resumo do mês" de `design/App de finanças onsen — protótipo iPhone.html`,
identificador `333f2428-5004-43ff-b703-276a4524089b`, tamanho base 390 × 844.
Requisitos: FR-001 a FR-018 de [spec.md](../spec.md). Contrato local; sem API.

## Tela

| Elemento | Referência base | Adaptação nativa |
|----------|-----------------|------------------|
| Fundo e rolagem | `#FBF4E5`; recuo 58 no topo, 18 nas laterais, 130 embaixo; blocos a 16 | Área segura; rolagem com espaço para a barra e o botão + |
| Saudação | 14 pt `#6B6258` ("Boa noite") | Pelo horário do aparelho |
| Mês | Zen Maru Gothic 30, altura de linha 1,1 | Cabeçalho acessível |
| Olho | 44 × 44, raio 14, `#F1E6D2`; ícone 22 `#2E2A25` aberto ou riscado | "Ocultar valores"/"Mostrar valores", estado anunciado |

## Cartão do saldo

Altura 214, raio 30, fundo `#F1E6D2`. Água `#9CC7BA` da base até o nível (18% a 80%), com
duas ondas (frente `#9CC7BA` 7 s; trás `#BEDCD2` 12 s, reversa) e dois vapores brancos
desfocados (5 s, o segundo 2,2 s depois). Conteúdo com recuo 22:

- "Saldo do mês até agora" 14 pt semibold `#4A433B`;
- valor Zen Maru Gothic 40, algarismos tabulares, contagem de 0,8 s até o valor;
- "Sobra prevista no fim do mês: **valor**" 14 pt `#3E3A34`;
- selo 13 pt semibold `#45512A` em `rgba(255,253,248,.82)`, raio 12, 14 abaixo.

Complemento: sem receitas, o selo diz "Nenhuma receita registrada neste mês". Para VoiceOver,
o cartão é um elemento: "Saldo do mês até agora, R$ 0,00. Sobra prevista no fim do mês,
R$ 0,00. {selo}". Água, ondas e vapor são decorativos.

## Indicadores

Grade de 3 colunas, espaço 10; cartões `#FFFCF5`, raio 20, recuo 14/12. Rótulo 13 pt
`#5E564D` com ícone 14: seta para cima verde `#5C6B34` (Receitas), seta para baixo
`#9C4A22` (Gastos), cartão `#5E564D` (Fatura). Valor 15 pt bold tabular. Fatura é botão e
leva a Contas. Complemento: sem cartão, o valor da Fatura é "Sem cartão". Com texto
ampliado, a grade passa a uma coluna.

## Capivara

76 × 76, pose calma, decorativa. Balão `#FFFCF5`, raio 16/16/16/4, 14 pt `#4A433B`, sombra
`0 4 14 rgba(80,60,40,.07)`, 18 acima da base, com fade.
Texto (complemento): "Oi, {primeiro nome}! Seu mês começa aqui. Conforme você registra, eu
mostro para onde o dinheiro vai."

## Seções

Cartões `#FFFCF5`, raio 24, recuo 18; título 17 pt bold, cabeçalho acessível. Linhas com
divisória `#F4EBDC`.

| Seção | Referência | Estado vazio (complemento) |
|-------|------------|----------------------------|
| Previstos para este mês | Rótulo 13 pt `#6B6258` à direita ("N a confirmar"); linhas 60 pt com chip 38, "Recebi"/"Paguei" | Rótulo "nada a confirmar"; texto 14 pt `#6B6258`: "Nada previsto por enquanto. Receitas e contas que se repetem aparecem aqui para você confirmar." |
| Para onde foi | Abas Gastos/Receitas em `#F4EBDC`, raio 12, botões 34 pt (alvo 44), selecionada `#FFFCF5`; barra 12 pt; linhas por categoria | Barra vazia em `#F4EBDC`; "Nenhum gasto registrado neste mês." ou "Nenhuma receita registrada neste mês." |
| Registros recentes | Linhas 58 pt com inicial em chip 38 | "Nenhum registro ainda. Use o botão + para registrar o primeiro." |

## Botão + e barra

Botão 64 × 64, raio 24, `#C4622E`, sombra `0 10 24 rgba(196,98,46,.35)`, a 22 da direita e
112 do fundo da tela; entra com giro (0,6 s, 0,3 s de atraso). "Adicionar registro".

Barra de 92 (área segura incluída), `rgba(246,240,230,.94)`, borda superior `#E8DBC6`; três
itens 76 × 52, 12 pt: atual `#45512A` bold com ícone preenchido `#ECEBD6`; demais `#6B6258`
semibold. Ícones: casa (Início), cartão (Contas), tigela de onsen (Metas). Abas anunciadas
como selecionadas.

## Destinos

| Destino | Conteúdo |
|---------|----------|
| Contas (provisório) | Título "Contas e cartões"; lista da conclusão (`SpaceSummaryList`); "A gestão completa de contas e cartões vem numa próxima etapa do protótipo."; "Adicionar outra conta" (verde `#5C6B34`, 48 pt) |
| Metas (provisório) | Título "Metas"; "As metas de economia vêm numa próxima etapa do protótipo." |
| Novo registro (provisório, sobre o Início) | "O registro de receitas e gastos vem na próxima etapa do protótipo."; "Voltar ao início" |

## Redução de movimento

Sem `enter`, ondas, vapor, contagem, `grow`, giro do botão + nem `pop`; conteúdo final
direto. Toque com escala 0,96 também é omitido.

## Complementos ao design

- Estados vazios, selo sem receita, "Sem cartão" e mensagem da capivara (dados reais).
- Destinos provisórios de Contas, Metas e novo registro.
- Grade dos indicadores em uma coluna com texto ampliado.

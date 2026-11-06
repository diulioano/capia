# Contrato de interface: Novo registro digitado

Referência: quadro "Novo registro" de `design/App de finanças onsen — protótipo iPhone.html`,
identificador `f5b9b259-abfa-43b6-993e-a9dc8456c772`, tamanho base 390 × 844, aba Digitar.
Registros no Início: quadro "Resumo do mês" (`333f2428-5004-43ff-b703-276a4524089b`) e
[contrato da 003](../../003-month-summary/contracts/month-summary-ui.md).
Requisitos: FR-001 a FR-020 de [spec.md](../spec.md). Contrato local; sem API.

## Cabeçalho (fixo)

Fundo `#FBF4E5`; recuo 58 no topo (área segura + 12), 18 nas laterais, 12 embaixo; espaço 14.

| Elemento | Referência base | Adaptação nativa |
|----------|-----------------|------------------|
| Fechar | 44 × 44, raio 14, `#F1E6D2`, ícone de fechar | "Fechar e voltar ao resumo" |
| Título | Zen Maru Gothic 20, centralizado: "Novo registro" no teclado, "Revisar registro" no formulário | Cabeçalho acessível |
| Abas | Grade de 3, espaço 4, recuo 4, raio 16, `#F1E6D2`; aba 40 de altura, raio 12, 14 pt bold, ícone 18; selecionada `#FFFCF5` com sombra `0 2 8 rgba(80,60,40,.10)` | Digitar, Falar, Foto; seleção anunciada |

## Teclado (fase valor)

| Elemento | Referência base | Adaptação nativa |
|----------|-----------------|------------------|
| Tipo | Dois botões de 38, raio 19, borda 2, 14 pt bold, espaço 8. Gasto selecionado `#FBE3CF`/borda `#C4622E`; Receita selecionada `#ECEBD6`/borda `#5C6B34`; não selecionado `#FFFCF5`/borda `#E5D6BE` | Par de opções; seleção anunciada |
| Pergunta | 14 pt `#6B6258`: "Quanto você gastou?" ou "Quanto você recebeu?" | |
| Valor | Zen Maru Gothic 50 bold tabular; `#9A8F82` em zero, `#2E2A25` com valor; salto de 0,22 s a cada tecla | Reduz a fonte para caber; valor anunciado a cada mudança |
| Cursor | 3 × 46, raio 2, `#C4622E`, pisca em passos de 1 s | Decorativo; fixo com redução de movimento |
| Teclas | Grade 3 × 4, espaço 8; 58 de altura, raio 18, `#FFFCF5`, Zen Maru Gothic 24 bold; ao tocar, `#E5D6BE` e escala 0,94. Ordem 1–9, 00, 0, ⌫ | ⌫ anunciado "Apagar"; "00" anunciado "Dois zeros" |
| Continuar | 58 de altura, raio 20, 17 pt bold, 12 acima; ativo `#5C6B34`/`#FBF7F0`; inativo `#DDD3C4`/`#6B6258` | Inativo anunciado como indisponível |

## Formulário (fase detalhes)

Rolagem com recuo 4/18 e 120 embaixo; blocos a 16.

| Elemento | Referência base | Adaptação nativa |
|----------|-----------------|------------------|
| Topo | Capivara 60 (pensativa sem poder salvar, feliz quando pode) + título 17 bold e subtítulo 14 `#6B6258` | "Só alguns detalhes" / "Escolha a categoria e pronto."; receita: "Só alguns detalhes" / "Escolha onde entrou e pronto." (complemento) |
| Valor | Rótulo 14 `#6B6258`; campo Zen Maru Gothic 46 bold, 66 de altura, centralizado; erro 14 pt `#9C4A22` "Informe um valor maior que zero." | `CentsField` com limite de 8 algarismos |
| Descrição | Rótulo 14 bold `#4A433B`; campo Zen Maru Gothic 22 bold, 48 de altura, linha inferior 2 `#E5D6BE` (`#5C6B34` em foco); "Ex.: mercado, café, farmácia" | Até 60 caracteres; tecla Concluir |
| Categoria | Rótulo 14 bold; fichas de 40, raio 20, borda 2, 14 pt semibold, ponto 8 × 8 raio 3 da cor; selecionada `#ECEBD6`/borda `#5C6B34`; "· sugerido" 11 pt bold `#84401E` | Grupo de opções; só no gasto |
| Pago com / Entrou em | Rótulo 14 bold; fichas de 44, raio 14, borda 2, 14 pt semibold | Contas pelo nome; cartões "Cartão {nome}"; receita só contas |
| Parcelas | Bloco `#FFFCF5`, raio 18, recuo 14/16; "Parcelas" bold + texto 13 `#6B6258`; botões 44 × 44 raio 14 `#F1E6D2` "−"/"+"; "3×" 18 bold tabular | Só gasto em cartão; "Menos parcelas"/"Mais parcelas" desabilitados nos limites; valor anunciado |
| Data | Rótulo 14 bold; fichas de 44, raio 14: Hoje, Ontem, Outra data | "Outra data" abre o calendário gráfico do iOS, até hoje, numa folha que sobe só até a altura do calendário (450 pt, com tela cheia disponível para texto ampliado), com o formulário visível atrás; escolher o dia fecha a folha, e a terceira ficha mostra `dd/mm` (decisão do usuário em 2026-11-06) |
| Barra de ações | Fixa embaixo: `#FBF4E5`, linha superior `#E8DBC6`, recuo 14/18/32, espaço 10. "Voltar" 56 de altura, raio 18, `#F1E6D2`, 16 bold; "Salvar" ocupa o resto, 17 bold, cores de Continuar | Respeita a área segura; o último campo rola acima da barra |

Cores das categorias (ponto da ficha, inicial nos recentes, barra de "Para onde foi"):
Mercado `#5C6B34`, Restaurantes `#C4622E`, Transporte `#C9A472`, Casa `#6FA798`, Lazer
`#D99A3C`, Saúde `#A8957A`, Compras `#B07A93`, Outros `#9A8F82`. Receitas usam as cores do
quadro "Resumo do mês" em sequência: `#5C6B34`, `#6FA798`, `#C9A472`, depois `#9A8F82`.

## Aviso "Registro salvo"

Posição: 14 das laterais, 24 acima da base (104 quando há barra de ações). Fundo `#2E2A25`,
raio 22, recuo 8/10/8/6, sombra `0 14 30 rgba(40,30,20,.3)`. Capivara comemorando 52; título
15 bold `#FBF7F0`; subtítulo 13 `#D8CFC2`; "Desfazer" 44 de altura, raio 12,
`rgba(255,255,255,.12)`, 14 bold `#F2C9A7`. Entra subindo 120% em 0,4 s; some após 4,2 s.

Subtítulo: `{+ }R$ valor · {nome exibido} · {conta ou Cartão nome}`; "+ " só na receita.
Complemento: falha de gravação usa o mesmo lugar e estilo, sem capivara comemorando, com
"Não deu para salvar agora. Tente de novo." e "Tentar de novo".

Acessibilidade: o aviso é anunciado ao aparecer; com VoiceOver, permanece até a próxima ação.

## Falar e Foto (complemento)

Área abaixo das abas, recuo 10/22/40, centralizada: capivara calma 150; texto Zen Maru
Gothic 20, `#4A433B`, altura de linha 1,4: "Registrar falando vem na próxima etapa do
protótipo. Por enquanto, use Digitar." (ou "por foto"); botão "Digitar" com o estilo de
Continuar ativo. Sem pedido de permissão.

## Início com registros

| Elemento | Regra |
|----------|-------|
| "Para onde foi" › Gastos | Barra de distribuição e linhas por categoria, com a cor da categoria, valor e percentual, como no quadro |
| "Para onde foi" › Receitas | Linhas pelo nome exibido, salário como "Salário" |
| "Registros recentes" | Até 5 linhas: inicial em círculo com a cor (receita `#ECEBD6`/`#45512A`; gasto: fundo claro da categoria), nome, subtítulo `{categoria · }{conta ou Cartão nome}{ · n×} · dd/mm`, valor "− R$" em `#2E2A25` ou "+ R$" em `#45512A`; ocultos: `R$ ••••` |
| Cartão do saldo | "Em contas hoje" com sinal, pela regra da 003 |
| Capivara | Com registros e sem salário a confirmar: "Seu mês está tomando forma, {primeiro nome}." |

## Movimento e redução

Entradas `.enter` 0,34 s (`cubic-bezier(.2,.8,.2,1)`, de 14 pt abaixo), toques com escala 0,94,
cursor, salto do valor e aviso conforme [research.md](../research.md) §10. Com Reduzir
Movimento, nenhuma dessas animações acontece, e o conteúdo aparece direto.

# Validar o resumo do mês do Capia

Guia da funcionalidade 003. Ambiente, conexão do iPhone e instalação: os mesmos de
`specs/001-get-started/quickstart.md` e `specs/002-initial-setup/quickstart.md`. Registre
resultados em `validation.md`.

## Testar e compilar

No Bash do Ubuntu, na raiz do repositório:

```bash
swift test --package-path ios/CapiaFlow
cd ios/Capia && xtool dev build
```

## Instalar

```bash
cd ios/Capia
USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb
```

Reinstalar por cima mantém o espaço guardado; o app abre no Início.

## Percursos de aceitação

Execute sem rede. Compare com o quadro "Resumo do mês" e com
[o contrato](contracts/month-summary-ui.md).

| Percurso | Ações | Resultado esperado |
|----------|-------|--------------------|
| Entrada | Concluir a configuração; "Ver meu mês" | Início, aba Início selecionada |
| Reabertura | Encerrar e reabrir | Abre direto no Início |
| Cabeçalho | Observar de manhã, à tarde ou à noite | Saudação correta; mês atual ("Novembro") |
| Saldo | Conta com saldo inicial R$ 1.234,56 | Saldo do mês R$ 0,00; sobra R$ 0,00; "Nenhuma receita registrada neste mês"; água no mínimo |
| Indicadores | Espaço com e sem cartão | Receitas/Gastos/Fatura R$ 0,00; sem cartão, "Sem cartão" |
| Capivara | Observar | Calma; "Oi, {nome}! Seu mês começa aqui..." |
| Seções | Rolar; alternar Gastos e Receitas | Textos de estado vazio; aba selecionada anunciada |
| Ocultar | Olho; depois de novo | "R$ ••••" em todos os valores, "Valores ocultos"; volta |
| Novo registro | + ; "Voltar ao início" | Destino provisório; retorno ao Início |
| Contas | Aba Contas e indicador Fatura | Lista de contas e cartões; aviso provisório |
| Outra conta | Contas → "Adicionar outra conta" → Poupança "Banco Seiva" → "Agora não" → "Ver meu mês" → Contas | Nova conta listada; continua após reabrir |
| Metas | Aba Metas; Início | Destino provisório; retorno ao mês |
| Toques rápidos | + e abas repetidos | Sem destinos empilhados |

## Acessibilidade e composição

1. VoiceOver: cabeçalhos, cartão do saldo lido como um resumo, abas e estado do olho; com
   valores ocultos, nenhum montante lido.
2. Reduzir Movimento: ondas paradas, sem vapor, contagem, entradas nem giro do +.
3. Maior tamanho de texto: indicadores em coluna; conteúdo acima da barra e do +.
4. Comparar com o HTML no tamanho base; registrar adaptações.

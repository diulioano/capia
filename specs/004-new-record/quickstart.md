# Validar o novo registro do Capia

Guia da funcionalidade 004. Ambiente, conexão do iPhone e instalação: os mesmos de
`specs/003-month-summary/quickstart.md`. Registre resultados em `validation.md`.

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

Reinstalar por cima mantém o espaço guardado. Um espaço anterior a esta funcionalidade abre
no Início sem registros.

## Preparação

Espaço com a conta corrente "Conta Aurora" (saldo inicial R$ 1.000,00), o cartão "Aurora"
(fecha dia 3, vence dia 10) e sem salário. Para conferir o espaço sem cartão, use um segundo
espaço ou reinstale do zero.

## Percursos de aceitação

Execute sem rede. Compare com o quadro "Novo registro" e com
[o contrato](contracts/new-record-ui.md). Valores esperados supõem um mês sem outros registros.

| Percurso | Ações | Resultado esperado |
|----------|-------|--------------------|
| Abrir | + no Início | "Novo registro", Digitar e Gasto selecionados, R$ 0,00 cinza, Continuar inativo |
| Teclado | 4, 2, 9, 0; ⌫; 0; 00 | R$ 42,90 → R$ 4,29 → R$ 42,90 → R$ 4.290,00; acima de R$ 999.999,99 ignora |
| Sugestão | 4290, Continuar, descrição "mercado do bairro" | Mercado "· sugerido"; capivara feliz; Salvar ativo |
| Gasto em conta | Salvar; fechar | Aviso "Registro salvo · R$ 42,90 · mercado do bairro · Conta Aurora"; no Início, Gastos R$ 42,90, saldo do mês − R$ 42,90, Em contas hoje R$ 957,10, Mercado 100%, recente "− R$ 42,90" |
| Reabertura | Encerrar e reabrir | Registro e valores iguais |
| Voltar e fechar | Continuar; Voltar; fechar | Valor preservado ao voltar; nada salvo ao fechar |
| Data | Ontem; Outra data num dia do mês anterior | Salvo com a data; mês anterior não altera Gastos, mas altera Em contas hoje |
| Receita | Receita, 115000, "Freela · site", Salvar | "Entrou em" só com contas, sem categoria; aviso com "+ R$ 1.150,00"; Receitas e saldo sobem; selo com percentual; Receitas › "Freela · site" |
| Receita sem descrição | Receita, 1000, Salvar | Aparece como "Receita" |
| Cartão à vista | Gasto 5000, Cartão Aurora, Lazer, em 5/11 | "À vista, na fatura de dezembro"; Em contas hoje não muda; Fatura soma R$ 50,00 |
| Parcelado | Gasto 60000, Cartão Aurora, 3× | "3× de R$ 200,00 · até fev"; Gastos +R$ 200,00; recente "− R$ 600,00 · 3×" |
| Resto | Gasto 10000 em 3× no cartão | Gastos +R$ 33,34 no mês |
| Troca de fonte | Cartão em 3×, depois Conta Aurora | Parcelas somem; volta a à vista |
| Sem cartão | Espaço sem cartão | Pago com só contas; nunca há Parcelas |
| Desfazer | Salvar; Desfazer | Formulário restaurado; Início e reabertura sem o registro |
| Aviso expira | Salvar; esperar | Some em cerca de 4 s; registro permanece |
| Falar e Foto | Acionar cada aba; Digitar | Avisos provisórios; nenhuma permissão; volta com tipo e valor |
| Toques rápidos | Salvar e Continuar repetidos | Nenhum registro duplicado nem tela empilhada |
| Ocultar | Olho no Início com registros | Recentes e categorias em "R$ ••••" |

Falha de gravação não é reproduzível no aparelho sem ferramentas; ela é coberta por testes
em `AppFlowTests` e registrada como não observada no iPhone.

## Acessibilidade e composição

1. VoiceOver: abas, tipo, categorias, fontes e data anunciam a seleção; o valor é lido a
   cada tecla; "Registro salvo" é anunciado e "Desfazer" é alcançável.
2. Reduzir Movimento: sem entradas, cursor piscando, salto do valor nem subida do aviso.
3. Maior tamanho de texto: teclado utilizável; formulário rola; barra de ações não cobre o
   último campo.
4. Comparar com o HTML no tamanho base; registrar adaptações.
